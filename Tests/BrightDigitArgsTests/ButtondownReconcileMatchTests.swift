import ButtondownKit
import Foundation
import Spinetail
import Testing

@testable import BrightDigitArgs

/// Buttondown-email matching rules: archive-slug fallback, imported-only
/// matching, and re-send dedup for `buttondown reconcile` (#127).
internal struct ButtondownReconcileMatchTests {
  private typealias Reconcile = Buttondown.ReconcileCommand
  private typealias Fix = ButtondownReconcileFixtures

  @Test internal func matchesButtondownEmailByArchiveSlugWhenSubjectHasNoNumber() {
    // #116's subject dropped the "#NNN" convention, but its archive slug carries
    // the number — it must UPDATE, not be treated as missing.
    let numbered = [
      Reconcile.NumberedCampaign(
        issueNo: 116,
        campaignID: "c116",
        subject: "Bushel v2.3.0: Screenshot Capture",
        sendTime: Fix.day1
      )
    ]
    let byIssueNo = Reconcile.emailsByIssueNo([
      Fix.email(
        id: "e116",
        subject: "Bushel v2.3.0: Screenshot Capture",
        absoluteURL:
          "https://buttondown.com/brightdigit/archive/"
          + "brightdigit-newsletter-issue-116-25-10-31/"
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
        issueNo: 50, campaignID: "c50", subject: "BrightDigit #50",
        sendTime: Fix.day1
      )
    ]
    let byIssueNo = Reconcile.emailsByIssueNo([
      Fix.email(id: "e50", subject: "BrightDigit #50", status: .sent)
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
        issueNo: 42, campaignID: "c42", subject: "BrightDigit #42",
        sendTime: Fix.day1
      )
    ]
    let byIssueNo = Reconcile.emailsByIssueNo([
      Fix.email(id: "e42", subject: "BrightDigit #42", status: .imported)
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
        sendTime: Fix.day1
      ),
      Reconcile.NumberedCampaign(
        issueNo: 9, campaignID: "resend", subject: "BrightDigit Newsletter #9 (resend)",
        sendTime: Fix.day3
      ),
    ]
    let byIssueNo = [9: Fix.email(id: "e9", subject: "BrightDigit Newsletter #9")]

    let plan = Reconcile.buildPlan(numbered: numbered, buttondownByIssueNo: byIssueNo)

    // One UPDATE, carrying the later campaign's id.
    #expect(plan.items.map(\.issueNo) == [9])
    let item = try #require(plan.items.first)
    #expect(item.campaignID == "resend")
    #expect(item.existingEmailID == "e9")
  }
}
