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
      self.minBodyWords = reader.read(Keys.minBodyWords)
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

    if config.execute {
      try await runExecute(plan: plan, mailchimp: mailchimp, buttondown: buttondown)
    } else {
      try await printDryRun(
        plan: plan,
        campaignCount: campaigns.count,
        emailCount: emails.count,
        mailchimp: mailchimp
      )
    }
  }

  /// Renders the "in Mailchimp, absent from Buttondown — skipped" advisory shown
  /// in both the dry run and the executed run. Empty when nothing is missing.
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

  /// Fetches a campaign's archive HTML from Mailchimp and cleans it to Markdown,
  /// which is the new/updated Buttondown body (Buttondown is Markdown-native).
  private func cleanedBody(
    forCampaignID campaignID: String,
    using mailchimp: MailchimpClient
  ) async throws -> String {
    let html = try await mailchimp.archiveHTML(forCampaignID: campaignID)
    return try Import.markdownGenerator.markdown(fromHTML: html)
  }

  /// A plan item resolved to its cleaned body and meaningful word count.
  private struct ResolvedItem {
    let item: PlanItem
    let body: String
    let words: Int
  }

  /// The plan items partitioned by the body-quality gate.
  private struct ResolvedUpdates {
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
  /// plan, shared by the dry run and the executed run so both see the same
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
      let body = try await cleanedBody(forCampaignID: item.campaignID, using: mailchimp)
      let words = Self.meaningfulWordCount(of: body)
      let resolved = ResolvedItem(item: item, body: body, words: words)
      if words >= config.minBodyWords {
        writable.append(resolved)
      } else {
        thin.append(resolved)
      }
    }
    return ResolvedUpdates(writable: writable, thin: thin)
  }

  /// Renders the "cleaned body too thin — skipped" advisory for the dry run and
  /// the executed run. Empty when the gate rejected nothing.
  private func thinLines(_ thin: [ResolvedItem]) -> [String] {
    guard !thin.isEmpty else {
      return []
    }
    var lines = [
      "",
      "Skipped (cleaned body under \(config.minBodyWords) words — not overwritten):",
    ]
    for resolved in thin {
      lines.append("  SKIP  #\(resolved.item.issueNo)  (\(resolved.words) words)  \(resolved.item.subject)")
    }
    return lines
  }

  /// Prints the reconciliation plan without performing any writes (the default).
  ///
  /// Shows totals, a per-issue CREATE/UPDATE line, whether issue #114 is in the
  /// CREATE (backfill) set, and a short cleaned-body preview for the first couple
  /// of CREATE issues so the HTML→Markdown cleanup can be eyeballed. Only the
  /// preview issues have their archive HTML fetched, keeping the dry run a light
  /// read that does not hammer Mailchimp's archive endpoint.
  private func printDryRun(
    plan: Plan,
    campaignCount: Int,
    emailCount: Int,
    mailchimp: MailchimpClient
  ) async throws {
    let resolved = try await resolveUpdates(plan: plan, mailchimp: mailchimp)
    let writable = resolved.writable
    var lines: [String] = [
      "",
      "buttondown reconcile — DRY RUN (no writes; pass --execute to apply)",
      "====================================================================",
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
      lines.append("  UPDATE  #\(resolved.item.issueNo)  (\(resolved.words) words)  \(resolved.item.subject)")
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
    Self.log("--execute set: applying \(resolved.writable.count) UPDATE(s) to Buttondown …")
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
      let email = try await buttondown.updateEmail(id: id, body: entry.body)
      Self.log("UPDATED #\(item.issueNo) (\(email.id)): \(item.subject)")
    }
    Self.log("done.")
  }
}

extension Buttondown.ReconcileCommand {
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
    text = String(String.UnicodeScalarView(text.unicodeScalars.filter { !spacerScalars.contains($0) }))

    return text
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
  /// overwrite a fuller archive body. It **defaults to a dry run** that only
  /// prints the plan; live writes require an explicit `--execute` flag. It never
  /// touches local `Content/newsletters/*.md`.
  public struct ReconcileCommand: ConfigKeyKit.Command {
    public static let commandName = "buttondown reconcile"
    public static let abstract =
      "Reconcile Buttondown against Mailchimp (dry run by default)."
    public static let helpText = """
      OVERVIEW: Reconcile the Buttondown newsletter archive against Mailchimp.

      Reads sent campaigns from Mailchimp (via Spinetail) and current emails from
      Buttondown, then plans an UPDATE (cleaned body) for each issue already
      present as an imported archive email. Updates only: absent issues are
      reported and skipped (never created), non-imported emails are never
      touched, and issues whose cleaned body is under --min-body-words are
      skipped. Defaults to a DRY RUN that only prints the plan; local
      Content/newsletters/*.md files are never touched.

      USAGE: brightdigitwg buttondown reconcile --mailchimp-api-key <key> \
      --mailchimp-list-id <id> [--buttondown-api-key <key>] \
      [--min-body-words <n>] [--execute]

      OPTIONS:
        --mailchimp-api-key <key>   Mailchimp API key. (required)
        --mailchimp-list-id <id>    Mailchimp list ID. (required)
        --buttondown-api-key <key>  Buttondown API key; falls back to env.
        --min-body-words <n>        Skip issues whose cleaned body has fewer than
                                    <n> meaningful words. Default 100; 0 disables.
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
