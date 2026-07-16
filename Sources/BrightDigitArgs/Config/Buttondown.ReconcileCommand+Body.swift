//
//  Buttondown.ReconcileCommand+Body.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

extension Buttondown.ReconcileCommand {
  internal enum BodySource: String, Equatable, Sendable {
    case selectedHTML = "selected-html"
    case legacyHTML = "legacy-html"
    case plainText = "plain-text"
  }

  internal enum Mode: Equatable, Sendable {
    case execute
    case previewDirectory(String)
  }

  internal struct BodyCandidate: Equatable, Sendable {
    internal let body: String
    internal let words: Int
    internal let source: BodySource
  }

  /// Modern Mailchimp editor blocks to retain, deliberately excluding all
  /// presentation-table ancestors, preview text, social chrome, and logos.
  internal static let modernContentSelector =
    ".mceText > *, .mceImageBlockContainer img:not(.mceLogo):not([alt=Logo])"

  /// Matches a bare/angle-bracketed social-network profile URL on its own line.
  private static let socialURLPattern =
    #"^<?https?://(?:www\.)?"#
    + #"(?:facebook|instagram|twitter|x|linkedin|youtube|threads)\.com/[^ ]*>?$"#

  /// Requires exactly one side-effect mode for every reconcile invocation.
  internal static func mode(
    execute: Bool,
    previewDirectory: String?
  ) throws -> Mode {
    let directory = nonBlank(previewDirectory)
    switch (execute, directory) {
    case (true, nil):
      return .execute
    case (false, .some(let path)):
      return .previewDirectory(path)
    case (false, nil):
      throw CommandError.invalidOptionCombination(
        "Provide exactly one of --execute or --preview-directory <path>."
      )
    case (true, .some):
      throw CommandError.invalidOptionCombination(
        "--execute and --preview-directory are mutually exclusive; provide exactly one."
      )
    }
  }

  /// Whether a trimmed line is Mailchimp view/unsubscribe/social chrome to drop.
  private static func isChromeLine(trimmed: String, lower: String) -> Bool {
    if lower.contains("view this email in your browser")
      || lower.contains("update your preferences")
      || lower.contains("unsubscribe from this list")
      || lower.contains("unsubscribe from these emails")
      || lower == "logo"
    {
      return true
    }
    return trimmed.range(
      of: socialURLPattern,
      options: [.regularExpression, .caseInsensitive]
    ) != nil
  }

  /// Whether a trimmed line begins the Mailchimp footer block (copyright /
  /// mailing address / preference boilerplate), after which everything is cut.
  private static func startsFooter(lower: String) -> Bool {
    lower.contains("copyright (c)") || lower.contains("copyright ©")
      || lower.hasPrefix("our mailing address is:")
      || lower.hasPrefix("want to change how you receive these emails?")
  }

  /// Cleans Mailchimp-authored text or Markdown without disturbing its prose.
  internal static func cleanMailchimpBody(_ body: String) -> String {
    var text = body.replacingOccurrences(
      of: #"(?is)\*\|IF(?:NOT)?:[^|]*\|\*.*?\*\|END:IF\|\*"#,
      with: "",
      options: .regularExpression
    )
    text = text.replacingOccurrences(
      of: #"\*\|[^|]*\|\*"#,
      with: "",
      options: .regularExpression
    )

    var output: [String] = []
    var footerStarted = false
    for line in text.components(separatedBy: .newlines) where !footerStarted {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      let lower = trimmed.lowercased()
      if startsFooter(lower: lower) {
        footerStarted = true
        continue
      }
      if isChromeLine(trimmed: trimmed, lower: lower) {
        continue
      }
      if trimmed.isEmpty {
        if !output.isEmpty, output.last?.isEmpty == false {
          output.append("")
        }
      } else {
        output.append(trimmed)
      }
    }
    while output.last?.isEmpty == true {
      output.removeLast()
    }
    return output.joined(separator: "\n")
  }

  internal static func bodyCandidate(
    from body: String,
    source: BodySource
  ) -> BodyCandidate {
    let cleaned = cleanMailchimpBody(body)
    return BodyCandidate(
      body: cleaned,
      words: meaningfulWordCount(of: cleaned),
      source: source
    )
  }

  /// Chooses a fallback only when the primary is thin and the fallback is a
  /// better recovery candidate.
  ///
  /// A passing primary always wins.
  internal static func preferredCandidate(
    primary: BodyCandidate,
    fallback: BodyCandidate,
    minimumWords: Int
  ) -> BodyCandidate {
    guard primary.words < minimumWords, fallback.words > primary.words else {
      return primary
    }
    return fallback
  }

  internal static func nonBlank(_ value: String?) -> String? {
    guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
      !trimmed.isEmpty
    else {
      return nil
    }
    return trimmed
  }

  /// Counts the *meaningful* words in a cleaned Markdown body — the words a
  /// reader actually sees.
  ///
  /// Modern Mailchimp/Buttondown template issues clean down to skeletons of
  /// images, empty links, and preheader spacer runs; those must not count as
  /// content. So this strips image syntax, replaces links with just their link
  /// text, removes bare URLs, and drops zero-width / spacer characters, then
  /// counts alphanumeric-bearing whitespace-separated tokens.
  /// - Parameter body: The cleaned Markdown body.
  /// - Returns: The number of meaningful words.
  internal static func meaningfulWordCount(of body: String) -> Int {
    var text = body
    // Images `![alt](url)` contribute nothing readable.
    text = text.replacingOccurrences(
      of: #"!\[[^\]]*\]\([^)]*\)"#, with: " ", options: .regularExpression
    )
    // Links `[text](url)` → keep only the visible text.
    text = text.replacingOccurrences(
      of: #"\[([^\]]*)\]\([^)]*\)"#, with: "$1", options: .regularExpression
    )
    // Bare/angle-bracketed URLs.
    text = text.replacingOccurrences(
      of: #"<?https?://[^\s>]+>?"#, with: " ", options: .regularExpression
    )
    // Zero-width joiners / soft hyphen / combining grapheme joiner / NBSP-likes
    // used as email-preheader spacers.
    let spacerScalars: Set<Unicode.Scalar> = [
      "\u{034F}", "\u{200B}", "\u{200C}", "\u{200D}", "\u{00AD}", "\u{00A0}",
      "\u{2060}", "\u{FEFF}",
    ]
    text = String(
      String.UnicodeScalarView(text.unicodeScalars.filter { !spacerScalars.contains($0) })
    )

    return
      text
      .split(whereSeparator: { $0.isWhitespace })
      .count { token in token.contains { $0.isLetter || $0.isNumber } }
  }
}
