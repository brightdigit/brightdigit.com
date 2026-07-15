import ButtondownKit
import Foundation
import Spinetail
import Testing

@testable import BrightDigitArgs

/// Unit tests for the pure planning logic behind `buttondown reconcile` (#127):
/// issue-number derivation and CREATE-vs-UPDATE classification.
internal struct ButtondownReconcilePlanTests {
  private typealias Reconcile = Buttondown.ReconcileCommand

  private static let day1 = Date(timeIntervalSince1970: 1_000_000)
  private static let day1_5 = Date(timeIntervalSince1970: 1_500_000)
  private static let day2 = Date(timeIntervalSince1970: 2_000_000)
  private static let day3 = Date(timeIntervalSince1970: 3_000_000)

  /// Builds a BrightDigit newsletter campaign (segment-tagged so it counts).
  private func campaign(
    id: String,
    subject: String,
    sendTime: Date,
    segment: String? = "brightdigit-business"
  ) -> MailchimpCampaign {
    MailchimpCampaign(
      id: id,
      longArchiveURL: "https://archive.example/\(id)",
      sendTime: sendTime,
      subjectLine: subject,
      title: subject,
      previewText: nil,
      segmentText: segment,
      socialCardImageURL: nil
    )
  }

  /// Builds a Buttondown email with the given id and subject.
  private func email(id: String, subject: String) -> Email {
    Email(
      id: id,
      subject: subject,
      body: "body",
      status: .imported,
      creationDate: Self.day1,
      modificationDate: Self.day1,
      absoluteURL: "https://buttondown.example/\(id)",
      description: "",
      image: ""
    )
  }

  @Test internal func numbersExplicitAndDateOrdersTrailingUnnumbered() {
    let campaigns = [
      // Trailing unnumbered (after the last numbered issue) → sequential 3.
      campaign(id: "c4", subject: "Introducing swift-build", sendTime: Self.day3),
      // Explicitly numbered.
      campaign(id: "c1", subject: "BrightDigit Newsletter #1", sendTime: Self.day1),
      campaign(id: "c2", subject: "BrightDigit #2", sendTime: Self.day2),
      // Interior unnumbered (before the last numbered issue) → skipped.
      campaign(id: "c3", subject: "Blog Updates", sendTime: Self.day1_5),
      // Not a BrightDigit newsletter (no segment, no marker) → excluded.
      campaign(id: "c5", subject: "Some other blast", sendTime: Self.day3, segment: nil),
    ]

    let numbered = Reconcile.numberedCampaigns(from: campaigns)

    #expect(numbered.map(\.issueNo) == [1, 2, 3])
    #expect(numbered.map(\.campaignID) == ["c1", "c2", "c4"])
  }

  @Test internal func indexesButtondownEmailsByParsedIssueNumber() {
    let emails = [
      email(id: "e98", subject: "BrightDigit Newsletter #98"),
      email(id: "e114", subject: "BrightDigit #114"),
      email(id: "eX", subject: "Welcome to the list!"),
    ]

    let byIssueNo = Reconcile.emailsByIssueNo(emails)

    #expect(byIssueNo.count == 2)
    #expect(byIssueNo[98]?.id == "e98")
    #expect(byIssueNo[114]?.id == "e114")
    #expect(byIssueNo[0] == nil)
  }

  @Test internal func classifiesMissingAsCreateAndPresentAsUpdate() {
    let numbered = [
      Reconcile.NumberedCampaign(
        issueNo: 114, campaignID: "c114", subject: "BrightDigit #114", sendTime: Self.day3
      ),
      Reconcile.NumberedCampaign(
        issueNo: 1, campaignID: "c1", subject: "BrightDigit Newsletter #1",
        sendTime: Self.day1
      ),
      Reconcile.NumberedCampaign(
        issueNo: 2, campaignID: "c2", subject: "BrightDigit #2", sendTime: Self.day2
      ),
    ]
    // Only #2 already exists in Buttondown.
    let byIssueNo = [2: email(id: "e2", subject: "BrightDigit #2")]

    let plan = Reconcile.buildPlan(numbered: numbered, buttondownByIssueNo: byIssueNo)

    // Sorted ascending by issue number.
    #expect(plan.map(\.issueNo) == [1, 2, 114])

    let creates = plan.filter { $0.action == .create }
    let updates = plan.filter { $0.action == .update }
    #expect(creates.map(\.issueNo) == [1, 114])
    #expect(updates.map(\.issueNo) == [2])

    // #114 must be backfilled (the known-missing issue).
    #expect(creates.contains { $0.issueNo == 114 })

    // The UPDATE carries the existing Buttondown email id; CREATEs do not.
    let update = try! #require(updates.first)
    #expect(update.existingEmailID == "e2")
    #expect(creates.allSatisfy { $0.existingEmailID == nil })
  }
}
