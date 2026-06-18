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

  // MARK: Definition lists

  internal func testDefinitionListRendersTermsAndDefinitions() throws {
    let html = """
      <dl>
        <dt>package.json</dt>
        <dd>for what node modules need to be installed</dd>
        <dt>Gruntfile.js</dt>
        <dd>the "make" file</dd>
      </dl>
      """
    let markdown = try sut.markdown(fromHTML: html)
    // Regression: <dl> used to be dropped entirely, losing all content.
    XCTAssertTrue(markdown.contains("**package.json**"), markdown)
    XCTAssertTrue(markdown.contains("for what node modules need to be installed"), markdown)
    XCTAssertTrue(markdown.contains("**Gruntfile.js**"), markdown)
    XCTAssertTrue(markdown.contains("the \"make\" file"), markdown)
  }

  internal func testDefinitionListPreservesInlineFormattingInTerm() throws {
    let html = """
      <dl>
        <dt><a href="http://nodejs.org/">NodeJS</a></dt>
        <dd>for building the project</dd>
      </dl>
      """
    let markdown = try sut.markdown(fromHTML: html)
    XCTAssertTrue(markdown.contains("[NodeJS](http://nodejs.org/)"), markdown)
    XCTAssertTrue(markdown.contains("for building the project"), markdown)
  }

  internal func testDefinitionListPreservesNestedBlockInDefinition() throws {
    let html = """
      <dl>
        <dt>Grunt</dt>
        <dd>install grunt globally
          <pre><code class="language-bash">npm -g install grunt</code></pre>
        </dd>
      </dl>
      """
    let markdown = try sut.markdown(fromHTML: html)
    XCTAssertTrue(markdown.contains("**Grunt**"), markdown)
    XCTAssertTrue(markdown.contains("install grunt globally"), markdown)
    // The nested code block inside the <dd> must survive.
    XCTAssertTrue(markdown.contains("npm -g install grunt"), markdown)
    XCTAssertTrue(markdown.contains("```bash"), markdown)
  }

  // MARK: Tables

  internal func testLayoutTableFlattensCellContent() throws {
    // Mailchimp newsletters wrap nearly all body content in layout tables.
    let html = """
      <table><tbody>
        <tr><td><p>First cell</p></td></tr>
        <tr><td><p>Second cell</p></td></tr>
      </tbody></table>
      """
    let markdown = try sut.markdown(fromHTML: html)
    // Regression: <table> used to be dropped, erasing the whole newsletter body.
    XCTAssertTrue(markdown.contains("First cell"), markdown)
    XCTAssertTrue(markdown.contains("Second cell"), markdown)
  }

  internal func testTablePreservesInlineFormattingAndLinks() throws {
    let html = """
      <table><tr><td><p>see <a href="https://example.com">the docs</a></p></td></tr></table>
      """
    let markdown = try sut.markdown(fromHTML: html)
    XCTAssertTrue(markdown.contains("[the docs](https://example.com)"), markdown)
  }

  internal func testNestedTableContentEmittedExactlyOnce() throws {
    let html = """
      <table><tr><td>
        <table><tr><td><p>inner only</p></td></tr></table>
      </td></tr></table>
      """
    let markdown = try sut.markdown(fromHTML: html)
    let occurrences = markdown.components(separatedBy: "inner only").count - 1
    // Regression guard: descendant-cell selection must not double-emit nested
    // table content.
    XCTAssertEqual(occurrences, 1, markdown)
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
