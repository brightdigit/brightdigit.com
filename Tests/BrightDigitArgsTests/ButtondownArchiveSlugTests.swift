import Testing

@testable import BrightDigitArgs

/// Covers the file-name slug taken from Buttondown's own archive URL (#122).
internal struct ButtondownArchiveSlugTests {
  private static func slug(archive: String, subject: String = "Subject") -> String {
    Import.ButtondownCommand.archiveSlug(
      for: ButtondownReconcileFixtures.email(
        id: "em_1", subject: subject, absoluteURL: archive
      )
    )
  }

  @Test internal func usesButtondownSlugRatherThanSlugifiedSubject() {
    // convertedToSlug() would yield `i-m-back-...-1-0` from this subject.
    #expect(
      Self.slug(
        archive:
          "https://buttondown.com/brightdigit/archive/"
          + "118-im-back-and-mistkit-is-closing-in-on-10/",
        subject: "I'm back — and MistKit is closing in on 1.0"
      ) == "im-back-and-mistkit-is-closing-in-on-10"
    )
  }

  @Test internal func keepsSlugThatCarriesNoIssueNumber() {
    #expect(
      Self.slug(
        archive:
          "https://buttondown.com/brightdigit/archive/"
          + "atleast-is-in-beta-the-watch-timer-that-tells-you/"
      ) == "atleast-is-in-beta-the-watch-timer-that-tells-you"
    )
  }

  @Test internal func stripsOnlyAnIssueNumberPrefix() {
    #expect(
      Self.slug(
        archive:
          "https://buttondown.com/brightdigit/archive/"
          + "119-the-honest-ai-conversation/"
      ) == "the-honest-ai-conversation"
    )
    // Four digits is a year, not an issue number.
    #expect(
      Self.slug(archive: "https://buttondown.com/brightdigit/archive/2026-in-review/")
        == "2026-in-review"
    )
  }

  @Test internal func fallsBackToTheSubjectWhenTheArchiveURLIsUnusable() {
    #expect(
      Self.slug(archive: "", subject: "The Honest AI Conversation")
        == "the-honest-ai-conversation"
    )
  }

  /// The fallback must never emit a raw subject.
  ///
  /// `convertedToSlug()` returns its input unchanged when the transform fails,
  /// which on Linux produced
  /// `120-I'm back — and MistKit is closing in on 1.0.md`. Asserting the same
  /// result on both platforms is the regression guard.
  @Test internal func fallbackNeverEmitsAnUnslugifiedSubject() {
    #expect(
      Self.slug(archive: "", subject: "I'm back — and MistKit is closing in on 1.0")
        == "i-m-back-and-mistkit-is-closing-in-on-1-0"
    )
  }
}
