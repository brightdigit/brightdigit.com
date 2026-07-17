import Testing

@testable import Contribute

@Suite("SwiftSoupMarkdownGenerator selected content")
internal struct SwiftSoupSelectedContentTests {
  private let sut = SwiftSoupMarkdownGenerator()

  @Test("Selected content fragments omit email layout chrome")
  internal func selectedContentFragmentsOmitLayoutChrome() throws {
    let html = """
      <span class="mcnPreviewText">Hidden preview</span>
      <table role="presentation"><tr><td>
        <div class="mceText"><p>First <a href="https://example.com">story</a>.</p></div>
        <div class="mceImageBlockContainer">
          <img class="mceLogo" src="https://example.com/logo.png" alt="Logo">
        </div>
        <div class="mceText"><h2>Second story</h2><p>More prose.</p></div>
        <div class="mceImageBlockContainer">
          <img src="https://example.com/story.png" alt="Story artwork">
        </div>
        <div class="mceSocialFollowBlockContainer">Social chrome</div>
      </td></tr></table>
      """

    let markdown = try sut.markdown(
      fromHTML: html,
      selecting: ".mceText > *, .mceImageBlockContainer img:not(.mceLogo):not([alt=Logo])"
    )

    #expect(markdown.contains("First [story](https://example.com)."))
    #expect(markdown.contains("## Second story"))
    #expect(markdown.contains("![Story artwork](https://example.com/story.png)"))
    #expect(!markdown.contains("Hidden preview"))
    #expect(!markdown.contains("logo.png"))
    #expect(!markdown.contains("Social chrome"))
    let first = try #require(markdown.firstRange(of: "First"))
    let second = try #require(markdown.firstRange(of: "Second"))
    #expect(first.lowerBound < second.lowerBound)
  }

  @Test("Selected content returns empty when selector does not match")
  internal func selectedContentReturnsEmptyWhenSelectorDoesNotMatch() throws {
    let markdown = try sut.markdown(fromHTML: "<p>legacy body</p>", selecting: ".mceText > *")
    #expect(markdown.isEmpty)
  }
}
