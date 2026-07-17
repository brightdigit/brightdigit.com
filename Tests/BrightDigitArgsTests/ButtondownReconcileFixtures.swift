import ButtondownKit
import Foundation
import Spinetail

@testable import BrightDigitArgs

/// Shared fixtures for the `buttondown reconcile` (#127) test suites.
internal enum ButtondownReconcileFixtures {
  internal static let day1 = Date(timeIntervalSince1970: 1_000_000)
  internal static let dayOneAndHalf = Date(timeIntervalSince1970: 1_500_000)
  internal static let day2 = Date(timeIntervalSince1970: 2_000_000)
  internal static let day3 = Date(timeIntervalSince1970: 3_000_000)

  /// Builds a BrightDigit newsletter campaign (segment-tagged so it counts).
  internal static func campaign(
    id: String,
    subject: String,
    sendTime: Date,
    segment: String? = "brightdigit-business",
    previewText: String? = nil,
    socialCardImageURL: String? = nil
  ) -> MailchimpCampaign {
    MailchimpCampaign(
      id: id,
      longArchiveURL: "https://archive.example/\(id)",
      sendTime: sendTime,
      subjectLine: subject,
      title: subject,
      previewText: previewText,
      segmentText: segment,
      socialCardImageURL: socialCardImageURL
    )
  }

  /// Builds a Buttondown email with the given id and subject.
  internal static func email(
    id: String,
    subject: String,
    status: EmailStatus = .imported,
    absoluteURL: String? = nil
  ) -> Email {
    Email(
      id: id,
      subject: subject,
      body: "body",
      status: status,
      creationDate: day1,
      modificationDate: day1,
      absoluteURL: absoluteURL ?? "https://buttondown.example/\(id)",
      description: "",
      image: ""
    )
  }
}
