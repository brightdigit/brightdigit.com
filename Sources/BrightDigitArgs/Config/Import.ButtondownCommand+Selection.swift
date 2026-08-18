//
//  Import.ButtondownCommand+Selection.swift
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

import BrightDigitSite
import ButtondownKit
import Contribute
import ContributeButtondown
import Foundation

extension Import.ButtondownCommand {
  /// The image used when a Buttondown email supplies no preview image, so the
  /// site's required `featuredImage` metadata is always present.
  private static let featuredImageFallback: URL = {
    guard
      let url = URL(string: "https://brightdigit.com/android-chrome-512x512.png")
    else {
      preconditionFailure("Invalid featuredImage fallback URL")
    }
    return url
  }()

  /// The only characters a newsletter file name may contain after the number.
  private static let slugSafeScalars = CharacterSet(
    charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-"
  )

  /// Matches an issue-number prefix at the start of a Buttondown archive slug.
  ///
  /// Deliberately 1-3 digits: an issue number is stripped, a slug that opens
  /// with a year (`2026-in-review`) keeps it.
  private static let issuePrefixRegex: NSRegularExpression = {
    do {
      return try NSRegularExpression(pattern: #"^\d{1,3}-"#, options: [])
    } catch {
      preconditionFailure("Invalid issuePrefixRegex pattern: \(error)")
    }
  }()

  /// Logs an `import buttondown:` diagnostic line to stderr.
  internal static func logImport(_ message: String) {
    FileHandle.standardError.write(Data("import buttondown: \(message)\n".utf8))
  }

  /// Reduces a string to slug-safe characters, unconditionally.
  ///
  /// Deliberately not a bare ``BrightDigitSite`` `convertedToSlug()`: that
  /// returns its input UNCHANGED when the transform fails, which on Linux is
  /// how CI wrote `120-I'm back — and MistKit is closing in on 1.0.md` into
  /// `Content/newsletters`. This can only ever emit `[a-z0-9-]`.
  private static func slugified(_ value: String) -> String {
    let mapped = value.lowercased().unicodeScalars.map { scalar -> Character in
      slugSafeScalars.contains(scalar) ? Character(scalar) : "-"
    }
    return String(mapped)
      .split(separator: "-", omittingEmptySubsequences: true)
      .joined(separator: "-")
  }

  /// The slug Buttondown itself publishes an email under, read from the last
  /// path component of its archive URL (`.../archive/<slug>/`).
  ///
  /// Preferred over slugifying the subject locally. `convertedToSlug()` splits
  /// on apostrophes and periods, so "I'm back — and MistKit is closing in on
  /// 1.0" became `i-m-back-...-1-0` while Buttondown publishes it as
  /// `im-back-...-10`; taking Buttondown's own slug keeps the file name, the
  /// site URL and the archive URL spelled the same way.
  ///
  /// Any issue-number prefix is dropped, because
  /// ``fileNameWithoutExtensionFromSource(_:)`` re-adds the zero-padded number
  /// and ``existingSlugs(in:)`` reads the slug back as the part *after* that
  /// prefix -- left in place, issue 118 would round-trip as `118-118-...`.
  ///
  /// Falls back to slugifying the subject when the archive URL cannot be parsed
  /// or carries no usable last path component.
  internal static func archiveSlug(for email: Email) -> String {
    let fallback = slugified(email.subject.convertedToSlug())
    guard let url = URL(string: email.absoluteURL) else {
      return fallback
    }
    // A trailing slash is ignored, so `.../archive/<slug>/` yields `<slug>`.
    let component = url.lastPathComponent
    guard !component.isEmpty, component != "/" else {
      return fallback
    }
    let stripped = issuePrefixRegex.stringByReplacingMatches(
      in: component,
      options: [],
      range: NSRange(component.startIndex..., in: component),
      withTemplate: ""
    )
    // Buttondown slugs are already slug-safe; normalize anyway so the file name
    // cannot inherit anything unexpected from the archive URL.
    let slug = slugified(stripped)
    return slug.isEmpty ? fallback : slug
  }

  /// Builds a Buttondown client, preferring the explicit key and otherwise
  /// falling back to the `BUTTONDOWN_API_KEY` environment variable.
  internal static func makeClient(apiKey: String?) throws -> ButtondownClient {
    if let apiKey, !apiKey.isEmpty {
      return ButtondownClient(apiKey: apiKey)
    }
    return try ButtondownClient.fromEnvironment()
  }

  /// The `NNN-slug` file name (without extension) for a source.
  internal static func fileNameWithoutExtensionFromSource(
    _ source: ContributeButtondown.Newsletter.Source
  ) -> String {
    let paddedIssue = source.issueNo.description.padLeft(totalWidth: 3, byString: "0")
    return "\(paddedIssue)-\(source.slug)"
  }

  /// The `*.md` file names in `directory`, or `[]` when the directory does not
  /// exist yet (the expected first-run state).
  ///
  /// A read failure on a directory that *does* exist is logged rather than
  /// silently treated as empty — otherwise a misconfigured path would look like
  /// an empty archive and restart numbering from issue 1.
  private static func markdownFileNames(in directory: URL) -> [String] {
    let manager = FileManager.default
    var isDirectory: ObjCBool = false
    guard
      manager.fileExists(atPath: directory.path, isDirectory: &isDirectory),
      isDirectory.boolValue
    else {
      return []
    }
    do {
      return try manager.contentsOfDirectory(atPath: directory.path)
        .filter { $0.hasSuffix(".md") }
    } catch {
      logImport(
        "warning: could not read \(directory.path): \(error.localizedDescription)"
      )
      return []
    }
  }

  /// The set of issue numbers already present in `directory`.
  ///
  /// Reads the zero-padded `NNN-` file-name prefix (slug-independent), matching
  /// the naming the Mailchimp importer produced. Used to skip issues already on
  /// disk.
  internal static func existingIssueNumbers(in directory: URL) -> Set<Int> {
    var numbers: Set<Int> = []
    for name in markdownFileNames(in: directory) {
      let prefix = name.prefix { $0.isNumber }
      if prefix.count >= 1, let issueNo = Int(prefix) {
        numbers.insert(issueNo)
      }
    }
    return numbers
  }

  /// The set of slugs already present in `directory`.
  ///
  /// Parses the `slug` out of each `NNN-slug.md` file name (the leading digit
  /// run and its trailing `-` are the issue-number prefix; the remainder is the
  /// slug). The slug is derived from the email's stable subject, so it lets a
  /// re-run recognize an already-written issue even though the sequential number
  /// it would otherwise be assigned differs from run to run.
  internal static func existingSlugs(in directory: URL) -> Set<String> {
    var slugs: Set<String> = []
    for name in markdownFileNames(in: directory) {
      let base = name.dropLast(3)  // strip ".md"
      let digits = base.prefix { $0.isNumber }
      guard !digits.isEmpty else { continue }
      let remainder = base.dropFirst(digits.count)
      guard remainder.first == "-" else { continue }
      slugs.insert(String(remainder.dropFirst()))
    }
    return slugs
  }

  /// Resolves a numbered email into a writable ``Newsletter/Source``.
  ///
  /// Uses Buttondown's own archive slug -- see ``archiveSlug(for:)``.
  internal static func source(
    from numbered: ContributeButtondown.Newsletter.NumberedEmail
  ) throws -> ContributeButtondown.Newsletter.Source {
    let slug = archiveSlug(for: numbered.email)
    logImport("#\(numbered.issueNo) ← \(numbered.email.subject)")
    return try ContributeButtondown.Newsletter.Source(
      email: numbered.email,
      issueNo: numbered.issueNo,
      slug: slug,
      featuredImageFallback: featuredImageFallback
    )
  }
}
