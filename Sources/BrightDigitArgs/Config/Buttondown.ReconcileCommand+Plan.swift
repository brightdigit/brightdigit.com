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
  /// The kind of Buttondown write a reconcile plan item represents.
  internal enum Action: String, Equatable, Sendable {
    /// Backfill: the issue is absent from Buttondown, so create it as an
    /// archived / never-sent email.
    case create
    /// Clean: the issue already exists in Buttondown, so patch its body.
    case update
  }

  /// A Mailchimp campaign assigned its canonical BrightDigit issue number.
  internal struct NumberedCampaign: Equatable, Sendable {
    internal let issueNo: Int
    internal let campaignID: String
    internal let subject: String
    internal let sendTime: Date
  }

  /// A single reconcile action for one newsletter issue.
  internal struct PlanItem: Equatable, Sendable {
    internal let issueNo: Int
    internal let subject: String
    internal let campaignID: String
    internal let action: Action
    /// The existing Buttondown email id (UPDATE only); `nil` for CREATE.
    internal let existingEmailID: String?
  }

  /// Whether a campaign is a BrightDigit newsletter, by segment or subject line.
  ///
  /// Mirrors `Import.MailchimpCommand.isBrightDigitNewsletter` (which is private);
  /// kept identical so reconcile and import agree on which campaigns count.
  private static func isBrightDigitNewsletter(
    campaign: MailchimpCampaign,
    subjectLine: String
  ) -> Bool {
    let brightdigitSent =
      campaign.segmentText?.contains("brightdigit-business") == true
    return brightdigitSent || subjectLine.contains("BrightDigit Newsletter")
  }

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
    from campaigns: [MailchimpCampaign]
  ) -> [NumberedCampaign] {
    let newsletters =
      campaigns
      .compactMap { campaign -> (campaign: MailchimpCampaign, sendTime: Date)? in
        let subjectLine = campaign.subjectLine ?? ""
        guard
          isBrightDigitNewsletter(campaign: campaign, subjectLine: subjectLine),
          let sendTime = campaign.sendTime
        else {
          return nil
        }
        return (campaign, sendTime)
      }
      .sorted { $0.sendTime < $1.sendTime }

    let numbered =
      newsletters
      .filter {
        Import.MailchimpCommand.parseIssueNumber(from: $0.campaign.subjectLine ?? "")
          != nil
      }
    let maxExplicit =
      numbered
      .compactMap {
        Import.MailchimpCommand.parseIssueNumber(from: $0.campaign.subjectLine ?? "")
      }
      .max() ?? 0
    let lastNumberedDate = numbered.map(\.sendTime).max()

    var result: [NumberedCampaign] = []
    var trailingIssueNo = maxExplicit
    for (campaign, sendTime) in newsletters {
      let subjectLine = campaign.subjectLine ?? ""
      let issueNo: Int
      if let explicit = Import.MailchimpCommand.parseIssueNumber(from: subjectLine) {
        issueNo = explicit
      } else if let lastDate = lastNumberedDate, sendTime > lastDate {
        trailingIssueNo += 1
        issueNo = trailingIssueNo
      } else {
        continue
      }
      guard let campaignID = campaign.id else {
        continue
      }
      result.append(
        NumberedCampaign(
          issueNo: issueNo,
          campaignID: campaignID,
          subject: subjectLine,
          sendTime: sendTime
        )
      )
    }
    return result
  }

  /// Indexes Buttondown emails by the issue number parsed from their subject.
  ///
  /// Emails whose subject carries no BrightDigit issue number are ignored. When
  /// two emails share a number (shouldn't normally happen) the first wins.
  /// - Parameter emails: The current Buttondown emails.
  /// - Returns: A map from issue number to the corresponding email.
  internal static func emailsByIssueNo(_ emails: [Email]) -> [Int: Email] {
    var map: [Int: Email] = [:]
    for email in emails {
      guard
        let issueNo = Import.MailchimpCommand.parseIssueNumber(from: email.subject),
        map[issueNo] == nil
      else {
        continue
      }
      map[issueNo] = email
    }
    return map
  }

  /// Classifies each numbered campaign as CREATE (absent from Buttondown) or
  /// UPDATE (already present), the pure heart of the reconciliation.
  ///
  /// - Parameters:
  ///   - numbered: The Mailchimp campaigns with issue numbers assigned.
  ///   - buttondownByIssueNo: The current Buttondown emails indexed by issue
  ///     number (see ``emailsByIssueNo(_:)``).
  /// - Returns: One ``PlanItem`` per campaign, sorted by issue number ascending.
  internal static func buildPlan(
    numbered: [NumberedCampaign],
    buttondownByIssueNo: [Int: Email]
  ) -> [PlanItem] {
    numbered
      .sorted { $0.issueNo < $1.issueNo }
      .map { campaign in
        if let existing = buttondownByIssueNo[campaign.issueNo] {
          return PlanItem(
            issueNo: campaign.issueNo,
            subject: campaign.subject,
            campaignID: campaign.campaignID,
            action: .update,
            existingEmailID: existing.id
          )
        }
        return PlanItem(
          issueNo: campaign.issueNo,
          subject: campaign.subject,
          campaignID: campaign.campaignID,
          action: .create,
          existingEmailID: nil
        )
      }
  }
}
