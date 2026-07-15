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
    }

    /// Builds the Buttondown client: an explicit `--buttondown-api-key` if
    /// supplied, else the `BUTTONDOWN_API_KEY` environment fallback.
    internal func makeButtondownClient() throws -> ButtondownClient {
      if let buttondownAPIKey {
        return try ButtondownClient(apiKey: buttondownAPIKey)
      }
      return try ButtondownClient.fromEnvironment()
    }
  }

  private enum Keys {
    static let mailchimpAPIKey = OptionalConfigKey<String>("mailchimp-api-key")
    static let mailchimpListID = OptionalConfigKey<String>("mailchimp-list-id")
    static let buttondownAPIKey = OptionalConfigKey<String>("buttondown-api-key")
    static let execute = ConfigKey("execute", default: false)
  }

  /// Logs a `buttondown reconcile:` diagnostic line to stderr.
  internal static func log(_ message: String) {
    FileHandle.standardError.write(
      Data("buttondown reconcile: \(message)\n".utf8)
    )
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

  /// Fetches a campaign's archive HTML from Mailchimp and cleans it to Markdown,
  /// which is the new/updated Buttondown body (Buttondown is Markdown-native).
  private func cleanedBody(
    forCampaignID campaignID: String,
    using mailchimp: MailchimpClient
  ) async throws -> String {
    let html = try await mailchimp.archiveHTML(forCampaignID: campaignID)
    return try Import.markdownGenerator.markdown(fromHTML: html)
  }

  /// Prints the reconciliation plan without performing any writes (the default).
  ///
  /// Shows totals, a per-issue CREATE/UPDATE line, whether issue #114 is in the
  /// CREATE (backfill) set, and a short cleaned-body preview for the first couple
  /// of CREATE issues so the HTML→Markdown cleanup can be eyeballed. Only the
  /// preview issues have their archive HTML fetched, keeping the dry run a light
  /// read that does not hammer Mailchimp's archive endpoint.
  private func printDryRun(
    plan: [PlanItem],
    campaignCount: Int,
    emailCount: Int,
    mailchimp: MailchimpClient
  ) async throws {
    let creates = plan.filter { $0.action == .create }
    let updates = plan.filter { $0.action == .update }

    var lines: [String] = [
      "",
      "buttondown reconcile — DRY RUN (no writes; pass --execute to apply)",
      "====================================================================",
      "Mailchimp sent campaigns: \(campaignCount)",
      "Buttondown emails:        \(emailCount)",
      "Numbered newsletters:     \(plan.count)",
      "  CREATE (backfill):      \(creates.count)",
      "  UPDATE (clean body):    \(updates.count)",
      "",
      "Issue #114 in CREATE set: \(creates.contains { $0.issueNo == 114 } ? "YES" : "NO")",
      "",
      "Plan (by issue number):",
    ]
    for item in plan {
      let tag = item.action == .create ? "CREATE" : "UPDATE"
      lines.append("  \(tag)  #\(item.issueNo)  \(item.subject)")
    }
    print(lines.joined(separator: "\n"))

    let previewItems = Array(creates.prefix(2))
    guard !previewItems.isEmpty else {
      return
    }
    print("\nCleaned-body preview (\(previewItems.count) CREATE issue(s)):")
    for item in previewItems {
      let body = try await cleanedBody(forCampaignID: item.campaignID, using: mailchimp)
      print("\n--- #\(item.issueNo): \(item.subject) ---")
      print(Self.previewSnippet(of: body))
    }
  }

  /// A short, single-block preview of a cleaned body (first lines / characters).
  private static func previewSnippet(of body: String) -> String {
    let maxCharacters = 600
    let trimmed = body.prefix(maxCharacters)
    let suffix = body.count > maxCharacters ? "\n… (truncated)" : ""
    return trimmed + suffix
  }

  /// Applies the plan to Buttondown: `createArchived` for backfills,
  /// `updateEmail` for cleanups. Guarded behind `--execute`; **never** run live
  /// as part of automated work — this path is for Leo's explicit invocation.
  private func runExecute(
    plan: [PlanItem],
    mailchimp: MailchimpClient,
    buttondown: ButtondownClient
  ) async throws {
    Self.log("--execute set: applying \(plan.count) actions to Buttondown …")
    for item in plan {
      let body = try await cleanedBody(forCampaignID: item.campaignID, using: mailchimp)
      switch item.action {
      case .create:
        let email = try await buttondown.createArchived(
          subject: item.subject,
          body: body
        )
        Self.log("CREATED #\(item.issueNo) (\(email.id)): \(item.subject)")
      case .update:
        guard let id = item.existingEmailID else {
          continue
        }
        let email = try await buttondown.updateEmail(id: id, body: body)
        Self.log("UPDATED #\(item.issueNo) (\(email.id)): \(item.subject)")
      }
    }
    Self.log("done.")
  }
}

extension Buttondown {
  /// ConfigKeyKit-based command for reconciling the Buttondown newsletter
  /// archive against Mailchimp (issue #127).
  ///
  /// Registers under the two-token name `buttondown reconcile` and is dispatched
  /// by ``CommandDispatcher``. Reads sent campaigns from Mailchimp (via
  /// Spinetail) and the current emails from Buttondown, derives an issue number
  /// for each, and builds a plan: CREATE (as an archived / never-sent email) any
  /// issue missing from Buttondown, else UPDATE its body with the cleaned
  /// Markdown. It **defaults to a dry run** that only prints the plan; live
  /// Buttondown writes require an explicit `--execute` flag. It never touches
  /// local `Content/newsletters/*.md`.
  public struct ReconcileCommand: ConfigKeyKit.Command {
    public static let commandName = "buttondown reconcile"
    public static let abstract =
      "Reconcile the Buttondown newsletter archive against Mailchimp (dry run by default)."
    public static let helpText = """
      OVERVIEW: Reconcile the Buttondown newsletter archive against Mailchimp.

      Reads sent campaigns from Mailchimp (via Spinetail) and current emails from
      Buttondown, then plans a CREATE (archived / never-sent) for each issue
      missing from Buttondown and an UPDATE (cleaned body) for each issue already
      present. Defaults to a DRY RUN that only prints the plan; local
      Content/newsletters/*.md files are never touched.

      USAGE: brightdigitwg buttondown reconcile --mailchimp-api-key <key> \
      --mailchimp-list-id <id> [--buttondown-api-key <key>] [--execute]

      OPTIONS:
        --mailchimp-api-key <key>   Mailchimp API key. (required)
        --mailchimp-list-id <id>    Mailchimp list ID. (required)
        --buttondown-api-key <key>  Buttondown API key. Falls back to
                                    BUTTONDOWN_API_KEY if omitted.
        --execute                   Apply the plan to Buttondown. WITHOUT this
                                    flag the command only prints the plan and
                                    performs no writes.
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
