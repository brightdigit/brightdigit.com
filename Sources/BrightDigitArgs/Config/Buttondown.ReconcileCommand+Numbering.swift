//
//  Buttondown.ReconcileCommand+Numbering.swift
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
import Spinetail

extension Buttondown.ReconcileCommand {
  /// Whether a campaign is a BrightDigit newsletter, by segment or subject line.
  ///
  /// Mirrors `Import.MailchimpCommand.isBrightDigitNewsletter` (which is private);
  /// kept identical so reconcile and import agree on which campaigns count.
  private static func isBrightDigitNewsletter(
    campaign: Campaign,
    subjectLine: String
  ) -> Bool {
    let brightdigitSent =
      campaign.segmentText?.contains("brightdigit-business") == true
    return brightdigitSent || subjectLine.contains("BrightDigit Newsletter")
  }

  /// Filters and orders sent BrightDigit newsletters by send time.
  /// - Parameter campaigns: Every sent campaign returned by Mailchimp.
  /// - Returns: BrightDigit newsletter campaigns with send times, oldest first.
  internal static func sortedNewsletters(
    from campaigns: [Campaign]
  ) -> [(campaign: Campaign, sendTime: Date)] {
    campaigns
      .compactMap { campaign -> (campaign: Campaign, sendTime: Date)? in
        let subjectLine = campaign.subjectLine ?? ""
        guard
          isBrightDigitNewsletter(campaign: campaign, subjectLine: subjectLine),
          let sendTime = campaign.sendTime
        else {
          return nil
        }
        return (campaign, sendTime)
      }
      // Sort::sorted is not stable, so campaigns sharing a sendTime would otherwise
      // resolve nondeterministically — and dedupedByLatestSend keeps whichever comes
      // first, changing which campaignID's body gets written. Break ties on id.
      .sorted {
        if $0.sendTime != $1.sendTime {
          return $0.sendTime < $1.sendTime
        }
        return ($0.campaign.id ?? "") < ($1.campaign.id ?? "")
      }
  }

  /// Parses an explicit newsletter issue number from a campaign subject.
  /// - Parameter campaign: The campaign whose subject should be parsed.
  /// - Returns: The explicit issue number, if the subject contains one.
  internal static func explicitIssueNumber(for campaign: Campaign) -> Int? {
    Import.MailchimpCommand.parseIssueNumber(from: campaign.subjectLine ?? "")
  }

  /// The highest explicit issue number and the send time of the latest explicitly
  /// numbered issue, which together anchor the trailing-unnumbered sequence.
  ///
  /// Parses each subject once rather than re-running the regex per lookup.
  /// - Parameter newsletters: Newsletter campaigns in send-time order.
  internal static func numberingAnchor(
    for newsletters: [(campaign: Campaign, sendTime: Date)]
  ) -> (maxExplicit: Int, lastNumberedDate: Date?) {
    let numbered = newsletters.compactMap { entry -> (issueNo: Int, sendTime: Date)? in
      explicitIssueNumber(for: entry.campaign).map { ($0, entry.sendTime) }
    }
    return (numbered.map(\.issueNo).max() ?? 0, numbered.map(\.sendTime).max())
  }

  /// Resolves the issue number for one campaign.
  ///
  /// Prefers an explicit `#NNN` in the subject. Otherwise the campaign is a
  /// *trailing* unnumbered broadcast only if it was sent after the last numbered
  /// issue, in which case it continues the sequence; interior unnumbered
  /// broadcasts are one-off blasts and are skipped.
  /// - Returns: The issue number, or `nil` when the campaign is not a numbered issue.
  internal static func issueNumber(
    for campaign: Campaign,
    sendTime: Date,
    lastNumberedDate: Date?,
    trailingIssueNo: inout Int
  ) -> Int? {
    if let explicit = explicitIssueNumber(for: campaign) {
      return explicit
    }
    guard let lastDate = lastNumberedDate, sendTime > lastDate else {
      return nil
    }
    trailingIssueNo += 1
    return trailingIssueNo
  }
}
