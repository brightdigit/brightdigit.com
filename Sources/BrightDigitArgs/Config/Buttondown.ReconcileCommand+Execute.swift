//
//  Buttondown.ReconcileCommand+Execute.swift
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
import Contribute
import Foundation
import Spinetail

extension Buttondown.ReconcileCommand {
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

  /// Fetches a campaign's archive HTML and extracts its authored content.
  ///
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
  internal func resolveUpdates(
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
    let updateCount = resolved.writable.count
    Self.log("--execute set: applying \(updateCount) UPDATE(s) to Buttondown …")
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
