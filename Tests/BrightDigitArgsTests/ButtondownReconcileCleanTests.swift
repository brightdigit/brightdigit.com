import Foundation
import Testing

@testable import BrightDigitArgs

/// Word-count and body-cleaning logic behind `buttondown reconcile` (#127).
internal struct ButtondownReconcileCleanTests {
  private typealias Reconcile = Buttondown.ReconcileCommand

  @Test internal func meaningfulWordCountCountsOnlyVisibleProse() {
    let body = """
      Happy New Year! We shipped a new episode on estimation and there is a lot
      going on with Apple this month.
      """
    // 21 plain words.
    #expect(Reconcile.meaningfulWordCount(of: body) == 21)
  }

  @Test internal func meaningfulWordCountIgnoresImagesLinksURLsAndSpacers() {
    // A template-issue skeleton: a logo image, empty links, a bare URL, and a
    // preheader spacer run of zero-width joiners. None of it is readable prose.
    let spacer = String(repeating: "\u{034F}\u{200C}\u{00AD} ", count: 40)
    let body = """
      \(spacer)
      ![Logo](https://gallery.mailchimp.com/x/logo.png)

      [](https://brightdigit.com/episodes/203-milk-diary/)
      [](https://twitter.com/brightdigit)

      https://buttondown.com/brightdigit/archive/issue-113/
      """
    #expect(Reconcile.meaningfulWordCount(of: body) == 0)
  }

  @Test internal func meaningfulWordCountKeepsLinkText() {
    // Link text is visible prose and should count; the URL should not.
    let body = "Read [our estimation guide](https://brightdigit.com/guide) today."
    // "Read our estimation guide today" → 5 words.
    #expect(Reconcile.meaningfulWordCount(of: body) == 5)
  }

  @Test internal func mailchimpCleanerRemovesTemplateCruftAndKeepsProse() {
    let body = """
      [View this email in your browser](https://mailchi.mp/example)

      *|MC_PREVIEW_TEXT|*
      A useful paragraph with an [inline link](https://example.com/article).

      https://twitter.com/brightdigit

      logo

      *|IFNOT:ARCHIVE_PAGE|*
      Want to change how you receive these emails?
      *|END:IF|*
      Copyright (C) 2026 BrightDigit
      Our mailing address is:
      123 Main Street
      """

    let cleaned = Reconcile.cleanMailchimpBody(body)

    #expect(
      cleaned == "A useful paragraph with an [inline link](https://example.com/article).")
  }
}
