//
//  Buttondown.ReconcileCommand+PlanTypes.swift
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
    internal let previewText: String?
    internal let socialCardImageURL: String?

    internal init(
      issueNo: Int,
      campaignID: String,
      subject: String,
      sendTime: Date,
      previewText: String? = nil,
      socialCardImageURL: String? = nil
    ) {
      self.issueNo = issueNo
      self.campaignID = campaignID
      self.subject = subject
      self.sendTime = sendTime
      self.previewText = previewText
      self.socialCardImageURL = socialCardImageURL
    }
  }

  /// A single reconcile action for one newsletter issue.
  internal struct PlanItem: Equatable, Sendable {
    internal let issueNo: Int
    internal let subject: String
    internal let campaignID: String
    internal let action: Action
    /// The existing Buttondown email id (UPDATE only); `nil` for CREATE.
    internal let existingEmailID: String?
    /// The existing Buttondown email's status (UPDATE only); `nil` for CREATE.
    ///
    /// Re-checked immediately before writing so only ``EmailStatus/imported``
    /// emails are ever patched.
    internal let existingStatus: EmailStatus?
    internal let previewText: String?
    internal let socialCardImageURL: String?
    internal let publishDate: Date
  }

  /// The outcome of planning: the UPDATE actions plus the issue numbers that
  /// exist in Mailchimp but have no matching Buttondown email.
  internal struct Plan: Equatable, Sendable {
    /// One UPDATE per issue number that already exists in Buttondown, ascending.
    internal let items: [PlanItem]
    /// Numbered Mailchimp issues absent from Buttondown, skipped (never created).
    internal let missingIssueNos: [Int]
  }

  /// A plan item resolved to its cleaned body and meaningful word count.
  internal struct ResolvedItem {
    internal let item: PlanItem
    internal let body: String
    internal let words: Int
    internal let source: BodySource
  }

  /// The plan items partitioned by the body-quality gate.
  internal struct ResolvedUpdates {
    /// Issues whose cleaned body meets the word threshold — safe to write.
    internal let writable: [ResolvedItem]
    /// Issues whose cleaned body is too thin — skipped so reconcile never
    /// overwrites an archive body with an empty/skeleton clean.
    internal let thin: [ResolvedItem]
  }
}
