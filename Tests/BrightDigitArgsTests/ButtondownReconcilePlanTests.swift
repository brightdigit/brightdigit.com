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
  private static let dayOneAndHalf = Date(timeIntervalSince1970: 1_500_000)
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
  private func email(
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
      creationDate: Self.day1,
      modificationDate: Self.day1,
      absoluteURL: absoluteURL ?? "https://buttondown.example/\(id)",
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
      campaign(id: "c3", subject: "Blog Updates", sendTime: Self.dayOneAndHalf),
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

  @Test internal func presentIssuesUpdateAndAbsentIssuesAreSkippedNeverCreated() throws {
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
    // Only #2 already exists in Buttondown; #1 and #114 are absent.
    let byIssueNo = [2: email(id: "e2", subject: "BrightDigit #2")]

    let plan = Reconcile.buildPlan(numbered: numbered, buttondownByIssueNo: byIssueNo)

    // Only present issues become UPDATEs; absent issues are never created.
    #expect(plan.items.map(\.issueNo) == [2])
    #expect(plan.items.allSatisfy { $0.action == .update })

    // Absent issues are reported as missing (skipped), sorted ascending.
    #expect(plan.missingIssueNos == [1, 114])

    // The UPDATE carries the existing Buttondown email id.
    let update = try #require(plan.items.first)
    #expect(update.existingEmailID == "e2")
  }

  @Test internal func matchesButtondownEmailByArchiveSlugWhenSubjectHasNoNumber() {
    // #116's subject dropped the "#NNN" convention, but its archive slug carries
    // the number — it must UPDATE, not be treated as missing.
    let numbered = [
      Reconcile.NumberedCampaign(
        issueNo: 116,
        campaignID: "c116",
        subject: "Bushel v2.3.0: Screenshot Capture",
        sendTime: Self.day1
      )
    ]
    let byIssueNo = Reconcile.emailsByIssueNo([
      email(
        id: "e116",
        subject: "Bushel v2.3.0: Screenshot Capture",
        absoluteURL:
          "https://buttondown.com/brightdigit/archive/brightdigit-newsletter-issue-116-25-10-31/"
      )
    ])

    #expect(byIssueNo[116]?.id == "e116")

    let plan = Reconcile.buildPlan(numbered: numbered, buttondownByIssueNo: byIssueNo)
    #expect(plan.missingIssueNos.isEmpty)
    #expect(plan.items.map(\.issueNo) == [116])
    #expect(plan.items.first?.existingEmailID == "e116")
  }

  @Test internal func nonImportedEmailsAreNeverMatchedSoTheIssueIsSkipped() {
    // A real sent broadcast happens to parse to issue #50. It must NOT be a
    // match — reconcile only ever touches imported archive emails.
    let numbered = [
      Reconcile.NumberedCampaign(
        issueNo: 50, campaignID: "c50", subject: "BrightDigit #50", sendTime: Self.day1
      )
    ]
    let byIssueNo = Reconcile.emailsByIssueNo([
      email(id: "e50", subject: "BrightDigit #50", status: .sent)
    ])

    // The sent email is excluded from the index entirely.
    #expect(byIssueNo[50] == nil)

    let plan = Reconcile.buildPlan(numbered: numbered, buttondownByIssueNo: byIssueNo)
    #expect(plan.items.isEmpty)
    #expect(plan.missingIssueNos == [50])
  }

  @Test internal func updateItemsCarryTheImportedStatusForTheWriteGuard() throws {
    let numbered = [
      Reconcile.NumberedCampaign(
        issueNo: 42, campaignID: "c42", subject: "BrightDigit #42", sendTime: Self.day1
      )
    ]
    let byIssueNo = Reconcile.emailsByIssueNo([
      email(id: "e42", subject: "BrightDigit #42", status: .imported)
    ])

    let plan = Reconcile.buildPlan(numbered: numbered, buttondownByIssueNo: byIssueNo)
    let item = try #require(plan.items.first)
    #expect(item.existingStatus == .imported)
  }

  @Test internal func dedupesResendsKeepingLatestSend() throws {
    // Two campaigns share issue #9 (a Mailchimp re-send); the later send wins.
    let numbered = [
      Reconcile.NumberedCampaign(
        issueNo: 9, campaignID: "original", subject: "BrightDigit Newsletter #9",
        sendTime: Self.day1
      ),
      Reconcile.NumberedCampaign(
        issueNo: 9, campaignID: "resend", subject: "BrightDigit Newsletter #9 (resend)",
        sendTime: Self.day3
      ),
    ]
    let byIssueNo = [9: email(id: "e9", subject: "BrightDigit Newsletter #9")]

    let plan = Reconcile.buildPlan(numbered: numbered, buttondownByIssueNo: byIssueNo)

    // One UPDATE, carrying the later campaign's id.
    #expect(plan.items.map(\.issueNo) == [9])
    let item = try #require(plan.items.first)
    #expect(item.campaignID == "resend")
    #expect(item.existingEmailID == "e9")
  }
}
