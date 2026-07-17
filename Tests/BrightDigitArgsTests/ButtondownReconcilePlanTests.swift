import ButtondownKit
import Foundation
import Spinetail
import Testing

@testable import BrightDigitArgs

/// Issue-number derivation and CREATE-vs-UPDATE classification for the pure
/// planning logic behind `buttondown reconcile` (#127).
internal struct ButtondownReconcilePlanTests {
  private typealias Reconcile = Buttondown.ReconcileCommand
  private typealias Fix = ButtondownReconcileFixtures

  @Test internal func numbersExplicitAndDateOrdersTrailingUnnumbered() {
    let campaigns = [
      // Trailing unnumbered (after the last numbered issue) → sequential 3.
      Fix.campaign(
        id: "c4", subject: "Introducing swift-build", sendTime: Fix.day3
      ),
      // Explicitly numbered.
      Fix.campaign(
        id: "c1", subject: "BrightDigit Newsletter #1", sendTime: Fix.day1
      ),
      Fix.campaign(id: "c2", subject: "BrightDigit #2", sendTime: Fix.day2),
      // Interior unnumbered (before the last numbered issue) → skipped.
      Fix.campaign(
        id: "c3", subject: "Blog Updates", sendTime: Fix.dayOneAndHalf
      ),
      // Not a BrightDigit newsletter (no segment, no marker) → excluded.
      Fix.campaign(
        id: "c5", subject: "Some other blast", sendTime: Fix.day3, segment: nil
      ),
    ]

    let numbered = Reconcile.numberedCampaigns(from: campaigns)

    #expect(numbered.map(\.issueNo) == [1, 2, 3])
    #expect(numbered.map(\.campaignID) == ["c1", "c2", "c4"])
  }

  @Test internal func indexesButtondownEmailsByParsedIssueNumber() {
    let emails = [
      Fix.email(id: "e98", subject: "BrightDigit Newsletter #98"),
      Fix.email(id: "e114", subject: "BrightDigit #114"),
      Fix.email(id: "eX", subject: "Welcome to the list!"),
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
        issueNo: 114, campaignID: "c114", subject: "BrightDigit #114",
        sendTime: Fix.day3
      ),
      Reconcile.NumberedCampaign(
        issueNo: 1, campaignID: "c1", subject: "BrightDigit Newsletter #1",
        sendTime: Fix.day1
      ),
      Reconcile.NumberedCampaign(
        issueNo: 2, campaignID: "c2", subject: "BrightDigit #2", sendTime: Fix.day2
      ),
    ]
    // Only #2 already exists in Buttondown; #1 and #114 are absent.
    let byIssueNo = [2: Fix.email(id: "e2", subject: "BrightDigit #2")]

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

  @Test internal func campaignMetadataSurvivesNumberingAndPlanning() throws {
    let campaigns = [
      Fix.campaign(
        id: "c7",
        subject: "BrightDigit Newsletter #7",
        sendTime: Fix.day2,
        previewText: "  Issue preview  ",
        socialCardImageURL: "https://example.com/social.jpg"
      )
    ]
    let numbered = Reconcile.numberedCampaigns(from: campaigns)
    let plan = Reconcile.buildPlan(
      numbered: numbered,
      buttondownByIssueNo: [
        7: Fix.email(id: "e7", subject: "BrightDigit Newsletter #7")
      ]
    )

    let item = try #require(plan.items.first)
    #expect(item.previewText == "  Issue preview  ")
    #expect(item.socialCardImageURL == "https://example.com/social.jpg")
    #expect(item.publishDate == Fix.day2)
    #expect(Reconcile.nonBlank(item.previewText) == "Issue preview")
    #expect(Reconcile.nonBlank("  ") == nil)
  }
}
