//
//  Buttondown.ReconcileCommand.swift
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

import ButtondownKit
import ConfigKeyKit
import Configuration
import Contribute
import Foundation
import Spinetail

extension Buttondown.ReconcileCommand {
  /// Resolved configuration for the `buttondown reconcile` command.
  public struct Config: ConfigurationParseable {
    public typealias ConfigReader = Configuration.ConfigReader
    public typealias BaseConfig = Never

    internal let mailchimpAPIKey: String
    internal let mailchimpListID: String
    internal let buttondownAPIKey: String?
    internal let execute: Bool
    internal let previewDirectory: String?
    internal let minBodyWords: Int

    public init(
      configuration reader: Configuration.ConfigReader,
      base _: Never?
    ) async throws {
      guard let mailchimpAPIKey = reader.read(Keys.mailchimpAPIKey) else {
        throw CommandError.missingRequiredOption("--mailchimp-api-key")
      }
      self.mailchimpAPIKey = mailchimpAPIKey

      guard let mailchimpListID = reader.read(Keys.mailchimpListID) else {
        throw CommandError.missingRequiredOption("--mailchimp-list-id")
      }
      self.mailchimpListID = mailchimpListID

      self.buttondownAPIKey = reader.read(Keys.buttondownAPIKey)
      self.execute = reader.read(Keys.execute)
      self.previewDirectory = reader.read(Keys.previewDirectory)
      self.minBodyWords = reader.read(Keys.minBodyWords)
      _ = try Buttondown.ReconcileCommand.mode(
        execute: execute,
        previewDirectory: previewDirectory
      )
    }

    /// Builds the Buttondown client: an explicit `--buttondown-api-key` if
    /// supplied, else the `BUTTONDOWN_API_KEY` environment fallback.
    internal func makeButtondownClient() throws -> ButtondownClient {
      if let buttondownAPIKey {
        return ButtondownClient(apiKey: buttondownAPIKey)
      }
      return try ButtondownClient.fromEnvironment()
    }
  }

  private enum Keys {
    static let mailchimpAPIKey = OptionalConfigKey<String>("mailchimp-api-key")
    static let mailchimpListID = OptionalConfigKey<String>("mailchimp-list-id")
    static let buttondownAPIKey = OptionalConfigKey<String>("buttondown-api-key")
    static let execute = ConfigKey("execute", default: false)
    static let previewDirectory = OptionalConfigKey<String>("preview-directory")
    /// Minimum meaningful word count a cleaned body must have to be written.
    /// Modern Mailchimp/Buttondown template issues clean down to near-empty
    /// skeletons (images + empty links); this gate skips them so reconcile never
    /// overwrites an archive body with less than it had. `0` disables the gate.
    static let minBodyWords = ConfigKey("min-body-words", default: 100)
  }

  public func execute() async throws {
    let mailchimp = try MailchimpClient(apiKey: config.mailchimpAPIKey)
    let buttondown = try config.makeButtondownClient()

    Self.log("fetching Mailchimp sent campaigns for list \(config.mailchimpListID) …")
    let campaigns = try await mailchimp.sentCampaigns(forListID: config.mailchimpListID)
    Self.log("fetched \(campaigns.count) sent campaigns.")

    Self.log("fetching current Buttondown emails …")
    let emails = try await buttondown.listAllEmails()
    Self.log("fetched \(emails.count) Buttondown emails.")

    let numbered = Self.numberedCampaigns(from: campaigns)
    let byIssueNo = Self.emailsByIssueNo(emails)
    let plan = Self.buildPlan(numbered: numbered, buttondownByIssueNo: byIssueNo)

    switch try Self.mode(
      execute: config.execute,
      previewDirectory: config.previewDirectory
    ) {
    case .execute:
      try await runExecute(plan: plan, mailchimp: mailchimp, buttondown: buttondown)
    case .previewDirectory(let directory):
      try await runPreview(
        plan: plan,
        campaignCount: campaigns.count,
        emailCount: emails.count,
        mailchimp: mailchimp,
        directory: directory
      )
    }
  }

  /// Renders the "in Mailchimp, absent from Buttondown — skipped" advisory shown
  /// in both preview and execute reports. Empty when nothing is missing.
  private static func missingLines(_ missingIssueNos: [Int]) -> [String] {
    guard !missingIssueNos.isEmpty else {
      return []
    }
    let list = missingIssueNos.map { "#\($0)" }.joined(separator: ", ")
    return [
      "",
      "Skipped (in Mailchimp, absent from Buttondown; never created): \(list)",
    ]
  }

  /// Fetches a campaign's archive HTML and extracts its authored content.
  /// Modern Mailchimp templates expose content as discrete `.mceText` and
  /// image blocks; legacy campaigns retain the existing whole-document path.
  private func cleanedHTMLBody(from html: String) throws -> BodyCandidate {
    let selected = try Import.markdownGenerator.markdown(
      fromHTML: html,
      selecting: Self.modernContentSelector
    )
    if !selected.isEmpty {
      return Self.bodyCandidate(from: selected, source: .selectedHTML)
    }
    let legacy = try Import.markdownGenerator.markdown(fromHTML: html)
    return Self.bodyCandidate(from: legacy, source: .legacyHTML)
  }

  /// A plan item resolved to its cleaned body and meaningful word count.
  internal struct ResolvedItem {
    let item: PlanItem
    let body: String
    let words: Int
    let source: BodySource
  }

  /// The plan items partitioned by the body-quality gate.
  internal struct ResolvedUpdates {
    /// Issues whose cleaned body meets the word threshold — safe to write.
    let writable: [ResolvedItem]
    /// Issues whose cleaned body is too thin — skipped so reconcile never
    /// overwrites an archive body with an empty/skeleton clean.
    let thin: [ResolvedItem]
  }

  /// Fetches and cleans every UPDATE item's body, then partitions them by the
  /// `--min-body-words` quality gate.
  ///
  /// This is the one place that hits Mailchimp's archive endpoint for the whole
  /// plan, shared by preview and execute modes so both see the same
  /// classification. When the gate is `0` every item is writable.
  /// - Parameters:
  ///   - plan: The reconcile plan.
  ///   - mailchimp: The Mailchimp client.
  /// - Returns: The writable and thin partitions.
  private func resolveUpdates(
    plan: Plan,
    mailchimp: MailchimpClient
  ) async throws -> ResolvedUpdates {
    var writable: [ResolvedItem] = []
    var thin: [ResolvedItem] = []
    for item in plan.items {
      let content = try await mailchimp.campaignContent(forCampaignID: item.campaignID)
      guard let html = content.archiveHTML else {
        throw MailchimpClient.ClientError.missingHTML(campaignID: item.campaignID)
      }
      var candidate = try cleanedHTMLBody(from: html)
      if candidate.words < config.minBodyWords, let plainText = content.plainText {
        let fallback = Self.bodyCandidate(from: plainText, source: .plainText)
        candidate = Self.preferredCandidate(
          primary: candidate,
          fallback: fallback,
          minimumWords: config.minBodyWords
        )
      }
      let resolved = ResolvedItem(
        item: item,
        body: candidate.body,
        words: candidate.words,
        source: candidate.source
      )
      if candidate.words >= config.minBodyWords {
        writable.append(resolved)
      } else {
        thin.append(resolved)
      }
    }
    return ResolvedUpdates(writable: writable, thin: thin)
  }

  /// Renders the "cleaned body too thin — skipped" advisory for preview and
  /// execute modes. Empty when the gate rejected nothing.
  private func thinLines(_ thin: [ResolvedItem]) -> [String] {
    guard !thin.isEmpty else {
      return []
    }
    var lines = [
      "",
      "Skipped (cleaned body under \(config.minBodyWords) words — not overwritten):",
    ]
    for resolved in thin {
      lines.append(
        "  SKIP  #\(resolved.item.issueNo)  [\(resolved.source.rawValue), "
          + "\(resolved.words) words]  \(resolved.item.subject)"
      )
    }
    return lines
  }

  /// Prints the reconciliation plan without performing Buttondown writes.
  ///
  /// Shows totals, a per-issue CREATE/UPDATE line, whether issue #114 is in the
  /// CREATE (backfill) set, and a short cleaned-body preview for the first couple
  /// of CREATE issues so the HTML→Markdown cleanup can be eyeballed. Only the
  /// Every converted body is also exported by ``runPreview`` for full review.
  private func printPreviewReport(
    plan: Plan,
    campaignCount: Int,
    emailCount: Int,
    resolved: ResolvedUpdates
  ) {
    let writable = resolved.writable
    var lines: [String] = [
      "",
      "buttondown reconcile — PREVIEW (no Buttondown writes)",
      "====================================================",
      "Mailchimp sent campaigns: \(campaignCount)",
      "Buttondown emails:        \(emailCount)",
      "Numbered newsletters:     \(plan.items.count + plan.missingIssueNos.count)",
      "  UPDATE (clean body):    \(writable.count)",
      "  SKIP (thin body):       \(resolved.thin.count)",
      "  SKIP (absent, missing):  \(plan.missingIssueNos.count)",
    ]
    lines.append(contentsOf: thinLines(resolved.thin))
    lines.append(contentsOf: Self.missingLines(plan.missingIssueNos))
    lines.append("")
    lines.append("Plan (by issue number):")
    for resolved in writable {
      lines.append(
        "  UPDATE  #\(resolved.item.issueNo)  [\(resolved.source.rawValue), "
          + "\(resolved.words) words]  \(resolved.item.subject)"
      )
      lines.append("          \(Self.metadataSummary(for: resolved.item))")
    }
    print(lines.joined(separator: "\n"))

    let previewItems = Array(writable.prefix(2))
    guard !previewItems.isEmpty else {
      return
    }
    print("\nCleaned-body preview (\(previewItems.count) UPDATE issue(s)):")
    for resolved in previewItems {
      print("\n--- #\(resolved.item.issueNo): \(resolved.item.subject) ---")
      print(Self.previewSnippet(of: resolved.body))
    }
  }

  /// Resolves the plan, prints its report, and exports every converted body.
  private func runPreview(
    plan: Plan,
    campaignCount: Int,
    emailCount: Int,
    mailchimp: MailchimpClient,
    directory: String
  ) async throws {
    let resolved = try await resolveUpdates(plan: plan, mailchimp: mailchimp)
    printPreviewReport(
      plan: plan,
      campaignCount: campaignCount,
      emailCount: emailCount,
      resolved: resolved
    )
    let outputURL = URL(
      fileURLWithPath: directory,
      relativeTo: FileManager.default.currentDirectoryURL
    ).standardizedFileURL
    try Self.writePreview(
      resolved: resolved,
      missingIssueNos: plan.missingIssueNos,
      to: outputURL
    )
    print("\nConverted Markdown written to \(outputURL.path)")
  }

  /// Applies the plan to Buttondown: `updateEmail` for each existing issue.
  ///
  /// Only UPDATEs are applied — issues absent from Buttondown are reported and
  /// skipped, never created. Guarded behind `--execute`; **never** run live as
  /// part of automated work — this path is for Leo's explicit invocation.
  private func runExecute(
    plan: Plan,
    mailchimp: MailchimpClient,
    buttondown: ButtondownClient
  ) async throws {
    let resolved = try await resolveUpdates(plan: plan, mailchimp: mailchimp)
    for line in thinLines(resolved.thin) where !line.isEmpty {
      Self.log(line)
    }
    for line in Self.missingLines(plan.missingIssueNos) where !line.isEmpty {
      Self.log(line)
    }
    Self.log(
      "--execute set: applying \(resolved.writable.count) UPDATE(s) to Buttondown …")
    for entry in resolved.writable {
      let item = entry.item
      guard let id = item.existingEmailID else {
        continue
      }
      // Last-line safety: never patch anything but an imported archive email,
      // even if the plan somehow paired this issue with a draft/sent broadcast.
      guard item.existingStatus == .imported else {
        Self.log(
          "REFUSED #\(item.issueNo) (\(id)): status is "
            + "\(item.existingStatus?.rawValue ?? "unknown"), not imported — skipped."
        )
        continue
      }
      let email = try await buttondown.updateEmail(
        id: id,
        body: entry.body,
        description: Self.nonBlank(item.previewText),
        image: Self.nonBlank(item.socialCardImageURL),
        publishDate: item.publishDate
      )
      Self.log(
        "UPDATED #\(item.issueNo) (\(email.id)) [\(entry.source.rawValue), "
          + "\(entry.words) words]: \(item.subject)"
      )
    }
    Self.log("done.")
  }
}

extension Buttondown.ReconcileCommand {
  /// Modern Mailchimp editor blocks to retain, deliberately excluding all
  /// presentation-table ancestors, preview text, social chrome, and logos.
  internal static let modernContentSelector =
    ".mceText > *, .mceImageBlockContainer img:not(.mceLogo):not([alt=Logo])"

  internal enum BodySource: String, Equatable, Sendable {
    case selectedHTML = "selected-html"
    case legacyHTML = "legacy-html"
    case plainText = "plain-text"
  }

  internal enum Mode: Equatable, Sendable {
    case execute
    case previewDirectory(String)
  }

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

  internal struct BodyCandidate: Equatable, Sendable {
    internal let body: String
    internal let words: Int
    internal let source: BodySource
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
    for line in text.components(separatedBy: .newlines) {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      let lower = trimmed.lowercased()
      if footerStarted {
        continue
      }
      if lower.contains("copyright (c)") || lower.contains("copyright ©")
        || lower.hasPrefix("our mailing address is:")
        || lower.hasPrefix("want to change how you receive these emails?")
      {
        footerStarted = true
        continue
      }
      if lower.contains("view this email in your browser")
        || lower.contains("update your preferences")
        || lower.contains("unsubscribe from this list")
        || lower.contains("unsubscribe from these emails")
        || lower == "logo"
        || trimmed.range(
          of:
            #"^<?https?://(?:www\.)?(?:facebook|instagram|twitter|x|linkedin|youtube|threads)\.com/[^ ]*>?$"#,
          options: [.regularExpression, .caseInsensitive]
        ) != nil
      {
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
  /// better recovery candidate. A passing primary always wins.
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

  private static func metadataSummary(for item: PlanItem) -> String {
    let date = ISO8601DateFormatter().string(from: item.publishDate)
    let description = nonBlank(item.previewText) == nil ? "no" : "yes"
    let image = nonBlank(item.socialCardImageURL) == nil ? "no" : "yes"
    return "metadata: publish_date=\(date), description=\(description), image=\(image)"
  }

  /// Writes reviewable Markdown bodies plus an index into a preview directory.
  internal static func writePreview(
    resolved: ResolvedUpdates,
    missingIssueNos: [Int],
    to directory: URL
  ) throws {
    let fileManager = FileManager.default
    try fileManager.createDirectory(
      at: directory,
      withIntermediateDirectories: true
    )

    // Remove only files produced by an earlier preview, leaving unrelated
    // contents in a caller-supplied directory untouched.
    let generatedName = #"^\d{3}-(?:selected-html|legacy-html|plain-text)\.md$"#
    for file in try fileManager.contentsOfDirectory(atPath: directory.path)
    where file.range(of: generatedName, options: .regularExpression) != nil {
      try fileManager.removeItem(at: directory.appendingPathComponent(file))
    }

    let entries =
      resolved.writable.map { (resolved: $0, writable: true) }
      + resolved.thin.map { (resolved: $0, writable: false) }
    let sorted = entries.sorted { $0.resolved.item.issueNo < $1.resolved.item.issueNo }

    var index = [
      "# Buttondown reconcile preview",
      "",
      "No Buttondown writes were performed. Each linked file is the exact Markdown body",
      "that reconcile selected for that issue.",
      "",
      "| Issue | Gate | Source | Words | Publish date | Description | Image | Subject |",
      "| ---: | :---: | --- | ---: | --- | :---: | :---: | --- |",
    ]
    let dateFormatter = ISO8601DateFormatter()
    for entry in sorted {
      let resolved = entry.resolved
      let item = resolved.item
      let fileName = String(
        format: "%03d-%@.md",
        item.issueNo,
        resolved.source.rawValue
      )
      let body = resolved.body.hasSuffix("\n") ? resolved.body : resolved.body + "\n"
      try body.write(
        to: directory.appendingPathComponent(fileName),
        atomically: true,
        encoding: .utf8
      )
      let gate = entry.writable ? "UPDATE" : "SKIP"
      let description = nonBlank(item.previewText) == nil ? "no" : "yes"
      let image = nonBlank(item.socialCardImageURL) == nil ? "no" : "yes"
      let subject = item.subject
        .replacingOccurrences(of: "|", with: "\\|")
        .replacingOccurrences(of: "\n", with: " ")
      index.append(
        "| #\(item.issueNo) | \(gate) | [\(resolved.source.rawValue)](\(fileName)) | "
          + "\(resolved.words) | \(dateFormatter.string(from: item.publishDate)) | "
          + "\(description) | \(image) | \(subject) |"
      )
    }
    if !missingIssueNos.isEmpty {
      index.append("")
      index.append(
        "Absent from Buttondown (no converted file): "
          + missingIssueNos.map { "#\($0)" }.joined(separator: ", ")
      )
    }
    try (index.joined(separator: "\n") + "\n").write(
      to: directory.appendingPathComponent("README.md"),
      atomically: true,
      encoding: .utf8
    )
  }

  /// Logs a `buttondown reconcile:` diagnostic line to stderr.
  internal static func log(_ message: String) {
    FileHandle.standardError.write(
      Data("buttondown reconcile: \(message)\n".utf8)
    )
  }

  /// A short, single-block preview of a cleaned body (first lines / characters).
  private static func previewSnippet(of body: String) -> String {
    let maxCharacters = 600
    let trimmed = body.prefix(maxCharacters)
    let suffix = body.count > maxCharacters ? "\n… (truncated)" : ""
    return trimmed + suffix
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

extension Buttondown {
  /// ConfigKeyKit-based command for reconciling the Buttondown newsletter
  /// archive against Mailchimp (issue #127).
  ///
  /// Registers under the two-token name `buttondown reconcile` and is dispatched
  /// by ``CommandDispatcher``. Reads sent campaigns from Mailchimp (via
  /// Spinetail) and the current emails from Buttondown, derives an issue number
  /// for each, and plans an UPDATE (cleaned body) for every issue already present
  /// as an imported archive email. It **only ever updates**: issues absent from
  /// Buttondown are reported and skipped (never created), non-imported emails are
  /// never touched, and issues whose cleaned body falls under `--min-body-words`
  /// are skipped so a template issue that cleans to an empty skeleton can't
  /// overwrite a fuller archive body. Every invocation must choose exactly one
  /// mode: `--preview-directory` exports reviewable Markdown without Buttondown
  /// writes, while `--execute` applies updates. It never touches local
  /// `Content/newsletters/*.md`.
  public struct ReconcileCommand: ConfigKeyKit.Command {
    public static let commandName = "buttondown reconcile"
    public static let abstract =
      "Preview or execute Buttondown reconciliation against Mailchimp."
    public static let helpText = """
      OVERVIEW: Reconcile the Buttondown newsletter archive against Mailchimp.

      Reads sent campaigns from Mailchimp (via Spinetail) and current emails from
      Buttondown, then plans an UPDATE (cleaned body) for each issue already
      present as an imported archive email. Updates only: absent issues are
      reported and skipped (never created), non-imported emails are never
      touched, and issues whose cleaned body is under --min-body-words are
      skipped. Exactly one of --preview-directory or --execute is required;
      local Content/newsletters/*.md files are never touched.

      USAGE: brightdigitwg buttondown reconcile --mailchimp-api-key <key> \
      --mailchimp-list-id <id> [--buttondown-api-key <key>] \
      [--min-body-words <n>] \
      (--execute | --preview-directory <path>)

      OPTIONS:
        --mailchimp-api-key <key>   Mailchimp API key. (required)
        --mailchimp-list-id <id>    Mailchimp list ID. (required)
        --buttondown-api-key <key>  Buttondown API key; falls back to env.
        --min-body-words <n>        Skip issues whose cleaned body has fewer than
                                    <n> meaningful words. Default 100; 0 disables.
        --preview-directory <path>  Export converted Markdown and an index without
                                    writing to Buttondown.
        --execute                   Apply the plan to Buttondown.
        -h, --help                  Show help information.

      Each option may also be supplied via an uppercased, underscore-separated
      environment variable (e.g. MAILCHIMP_API_KEY, BUTTONDOWN_API_KEY).
      """

    private let config: Config

    public init(config: Config) {
      self.config = config
    }
  }
}
