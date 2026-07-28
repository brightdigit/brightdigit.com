//
//  Buttondown.ReconcileCommand+Plan.swift
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
import Foundation
import Spinetail

extension Buttondown.ReconcileCommand {
  /// Matches the `issue-NNN` segment embedded in a Buttondown archive URL/slug.
  ///
  /// For example `.../archive/brightdigit-newsletter-issue-117-26-12-10/`.
  ///
  /// Recent issues dropped the `#NNN` convention from their subject line (e.g.
  /// "Introducing swift-build …"), but the imported Buttondown email still carries
  /// the number in its archive slug. Parsing the slug lets those issues match
  /// their existing email instead of being misclassified as a backfill CREATE.
  private static let archiveIssueNoRegex: NSRegularExpression = {
    do {
      return try NSRegularExpression(pattern: #"(?i)issue-(\d+)"#, options: [])
    } catch {
      preconditionFailure("Invalid archiveIssueNoRegex pattern: \(error)")
    }
  }()

  /// Assigns each BrightDigit newsletter campaign its canonical issue number.
  ///
  /// Mirrors `Import.MailchimpCommand.selectCampaigns` and reuses its
  /// ``Import/MailchimpCommand/parseIssueNumber(from:)``: keep BrightDigit
  /// newsletters that have a send time, sort oldest-first, assign the number
  /// parsed from the subject line, number trailing *unnumbered* campaigns
  /// sequentially after the last explicitly-numbered issue, and skip interior
  /// unnumbered broadcasts (one-off blasts, not numbered newsletters).
  /// - Parameter campaigns: Every sent campaign returned by Mailchimp.
  /// - Returns: The numbered newsletters, in send-time (oldest-first) order.
  internal static func numberedCampaigns(
    from campaigns: [Campaign]
  ) -> [NumberedCampaign] {
    let newsletters = sortedNewsletters(from: campaigns)
    let anchor = numberingAnchor(for: newsletters)
    var result: [NumberedCampaign] = []
    var trailingIssueNo = anchor.maxExplicit
    for (campaign, sendTime) in newsletters {
      let subjectLine = campaign.subjectLine ?? ""
      // Checked before the numbering below so a campaign we cannot address never
      // consumes a trailing issue number.
      guard let campaignID = campaign.id else {
        Self.log("skipping campaign with no id: \(subjectLine)")
        continue
      }
      guard
        let issueNo = issueNumber(
          for: campaign,
          sendTime: sendTime,
          lastNumberedDate: anchor.lastNumberedDate,
          trailingIssueNo: &trailingIssueNo
        )
      else {
        continue
      }
      result.append(
        NumberedCampaign(
          issueNo: issueNo,
          campaignID: campaignID,
          subject: subjectLine,
          sendTime: sendTime,
          previewText: campaign.previewText,
          socialCardImageURL: campaign.socialCardImageURL
        )
      )
    }
    return result
  }

  /// Parses the issue number from a Buttondown email's archive URL/slug, if any.
  /// - Parameter absoluteURL: The email's ``ButtondownKit/Email/absoluteURL``.
  /// - Returns: The `issue-NNN` number embedded in the slug, or `nil`.
  internal static func parseIssueNumber(fromArchiveURL absoluteURL: String) -> Int? {
    let range = NSRange(absoluteURL.startIndex..<absoluteURL.endIndex, in: absoluteURL)
    guard
      let match = archiveIssueNoRegex.firstMatch(in: absoluteURL, range: range),
      match.numberOfRanges > 1,
      let numberRange = Range(match.range(at: 1), in: absoluteURL),
      let issueNumber = Int(absoluteURL[numberRange])
    else {
      return nil
    }
    return issueNumber
  }

  /// The issue number for a Buttondown email: the number embedded in its archive
  /// slug when present, else the number parsed from its subject line.
  ///
  /// The archive slug is preferred because it is the number the site assigned at
  /// import time and survives subject lines that dropped the `#NNN` convention.
  /// - Parameter email: The Buttondown email.
  /// - Returns: The email's issue number, or `nil` if neither source has one.
  internal static func issueNumber(for email: Email) -> Int? {
    parseIssueNumber(fromArchiveURL: email.absoluteURL)
      ?? Import.MailchimpCommand.parseIssueNumber(from: email.subject)
  }

  /// Indexes Buttondown emails by issue number (archive slug first, subject
  /// second; see ``issueNumber(for:)``).
  ///
  /// Only ``EmailStatus/imported`` emails are indexed: reconcile backfills the
  /// archive, so it must never overwrite a real `draft` or `sent` broadcast that
  /// happens to parse to an issue number. A non-imported email is treated as no
  /// match, so its issue is reported as skipped rather than updated. When two
  /// imported emails share a number (e.g. an old `-resend`/`-preview` archive
  /// duplicate) the first wins.
  /// - Parameter emails: The current Buttondown emails.
  /// - Returns: A map from issue number to the corresponding imported email.
  internal static func emailsByIssueNo(_ emails: [Email]) -> [Int: Email] {
    var map: [Int: Email] = [:]
    for email in emails {
      guard
        email.status == .imported,
        let issueNo = issueNumber(for: email),
        map[issueNo] == nil
      else {
        continue
      }
      map[issueNo] = email
    }
    return map
  }

  /// Collapses campaigns that share an issue number to a single canonical one,
  /// keeping the **latest** send (Mailchimp re-sends reuse the issue number, so
  /// several campaigns map to one number — the final send is the corrected copy).
  /// - Parameter numbered: The numbered campaigns, possibly with duplicates.
  /// - Returns: One campaign per issue number, latest `sendTime` winning.
  internal static func dedupedByLatestSend(
    _ numbered: [NumberedCampaign]
  ) -> [NumberedCampaign] {
    var byIssueNo: [Int: NumberedCampaign] = [:]
    for campaign in numbered {
      if let existing = byIssueNo[campaign.issueNo],
        existing.sendTime >= campaign.sendTime
      {
        continue
      }
      byIssueNo[campaign.issueNo] = campaign
    }
    return byIssueNo.values.sorted { $0.issueNo < $1.issueNo }
  }

  /// Classifies each numbered campaign as UPDATE (already in Buttondown) or a
  /// skipped miss (absent), the pure heart of the reconciliation.
  ///
  /// Re-sends are collapsed to the latest send (see ``dedupedByLatestSend(_:)``),
  /// so each issue number yields at most one action. Issues absent from
  /// Buttondown are **never** created here — they are returned as
  /// ``Plan/missingIssueNos`` for the caller to log and skip.
  ///
  /// - Parameters:
  ///   - numbered: The Mailchimp campaigns with issue numbers assigned.
  ///   - buttondownByIssueNo: The current Buttondown emails indexed by issue
  ///     number (see ``emailsByIssueNo(_:)``).
  /// - Returns: The ``Plan`` (UPDATE items ascending, plus missing issue numbers).
  internal static func buildPlan(
    numbered: [NumberedCampaign],
    buttondownByIssueNo: [Int: Email]
  ) -> Plan {
    var items: [PlanItem] = []
    var missing: [Int] = []
    for campaign in dedupedByLatestSend(numbered) {
      guard let existing = buttondownByIssueNo[campaign.issueNo] else {
        missing.append(campaign.issueNo)
        continue
      }
      items.append(
        PlanItem(
          issueNo: campaign.issueNo,
          subject: campaign.subject,
          campaignID: campaign.campaignID,
          action: .update,
          existingEmailID: existing.id,
          existingStatus: existing.status,
          previewText: campaign.previewText,
          socialCardImageURL: campaign.socialCardImageURL,
          publishDate: campaign.sendTime
        )
      )
    }
    return Plan(items: items, missingIssueNos: missing)
  }
}
