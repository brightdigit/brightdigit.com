import XCTest

@testable import Contribute

internal final class SwiftSoupMarkdownGeneratorTests: XCTestCase {
  private let sut = SwiftSoupMarkdownGenerator()

  // MARK: Headings

  internal func testHeadingLevels() throws {
    XCTAssertEqual(try sut.markdown(fromHTML: "<h1>One</h1>"), "# One")
    XCTAssertEqual(try sut.markdown(fromHTML: "<h2>Two</h2>"), "## Two")
    XCTAssertEqual(try sut.markdown(fromHTML: "<h3>Three</h3>"), "### Three")
    // Regression: h4 previously emitted level 3.
    XCTAssertEqual(try sut.markdown(fromHTML: "<h4>Four</h4>"), "#### Four")
    XCTAssertEqual(try sut.markdown(fromHTML: "<h5>Five</h5>"), "##### Five")
    // Regression: h6 was previously unhandled.
    XCTAssertEqual(try sut.markdown(fromHTML: "<h6>Six</h6>"), "###### Six")
  }

  // MARK: Inline formatting

  internal func testParagraphPreservesInlineFormatting() throws {
    let html = """
      <p>foo <a href="https://example.com">bar</a> \
      <strong>baz</strong> <em>qux</em> <code>zap</code></p>
      """
    let markdown = try sut.markdown(fromHTML: html)

    // Regression: nested inline elements used to be flattened to plain text.
    XCTAssertTrue(markdown.contains("[bar](https://example.com)"), markdown)
    XCTAssertTrue(markdown.contains("**baz**"), markdown)
    XCTAssertTrue(markdown.contains("*qux*"), markdown)
    XCTAssertTrue(markdown.contains("`zap`"), markdown)
    XCTAssertTrue(markdown.contains("foo"), markdown)
  }

  // MARK: Lists

  internal func testUnorderedList() throws {
    let markdown = try sut.markdown(fromHTML: "<ul><li>one</li><li>two</li></ul>")
    XCTAssertTrue(markdown.contains("- one"), markdown)
    XCTAssertTrue(markdown.contains("- two"), markdown)
  }

  internal func testOrderedList() throws {
    let markdown = try sut.markdown(fromHTML: "<ol><li>one</li><li>two</li></ol>")
    // swift-markdown's formatter emits "1." for each item (CommonMark
    // auto-increments ordered markers on render).
    XCTAssertTrue(markdown.contains("1. one"), markdown)
    XCTAssertTrue(markdown.contains("two"), markdown)
    XCTAssertFalse(markdown.contains("- one"), markdown)
  }

  // MARK: Block quotes, rules, images

  internal func testBlockQuote() throws {
    let markdown = try sut.markdown(fromHTML: "<blockquote><p>quoted</p></blockquote>")
    XCTAssertTrue(markdown.contains("> quoted"), markdown)
  }

  internal func testThematicBreak() throws {
    let markdown = try sut.markdown(fromHTML: "<p>a</p><hr><p>b</p>")
    XCTAssertTrue(markdown.contains("---"), markdown)
  }

  internal func testBlockImage() throws {
    let markdown = try sut.markdown(
      fromHTML: "<img src=\"image.png\" alt=\"An image\">"
    )
    XCTAssertEqual(markdown, "![An image](image.png)")
  }

  // MARK: Code blocks

  internal func testCodeBlockLanguageFromClass() throws {
    let html = "<pre><code class=\"language-swift\">let x = 1</code></pre>"
    let markdown = try sut.markdown(fromHTML: html)
    // Regression: language used to be hardcoded to "swift" regardless of input.
    XCTAssertTrue(markdown.contains("```swift"), markdown)
    XCTAssertTrue(markdown.contains("let x = 1"), markdown)
  }

  internal func testCodeBlockWithoutLanguage() throws {
    let markdown = try sut.markdown(fromHTML: "<pre><code>plain text</code></pre>")
    XCTAssertTrue(markdown.contains("plain text"), markdown)
    XCTAssertTrue(markdown.contains("```"), markdown)
    // No language identifier should be emitted on the opening fence.
    XCTAssertFalse(markdown.contains("```swift"), markdown)
  }

  // MARK: Stripped / empty content

  internal func testScriptAndIframeAreStripped() throws {
    let html = "<p>keep</p><script>evil()</script><iframe src=\"x\"></iframe>"
    let markdown = try sut.markdown(fromHTML: html)
    XCTAssertTrue(markdown.contains("keep"), markdown)
    XCTAssertFalse(markdown.contains("evil"), markdown)
  }

  internal func testEmptyInput() throws {
    XCTAssertEqual(try sut.markdown(fromHTML: ""), "")
    XCTAssertEqual(try sut.markdown(fromHTML: "   "), "")
  }
}
