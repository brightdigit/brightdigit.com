import Testing

@testable import Contribute

@Suite("SwiftSoupMarkdownGenerator")
internal struct SwiftSoupMarkdownGeneratorTests {
  private let sut = SwiftSoupMarkdownGenerator()

  // MARK: - Headings

  @Test("Heading levels h1 through h6")
  internal func headingLevels() throws {
    #expect(try sut.markdown(fromHTML: "<h1>One</h1>") == "# One")
    #expect(try sut.markdown(fromHTML: "<h2>Two</h2>") == "## Two")
    #expect(try sut.markdown(fromHTML: "<h3>Three</h3>") == "### Three")
    // Regression: h4 previously emitted level 3.
    #expect(try sut.markdown(fromHTML: "<h4>Four</h4>") == "#### Four")
    #expect(try sut.markdown(fromHTML: "<h5>Five</h5>") == "##### Five")
    // Regression: h6 was previously unhandled.
    #expect(try sut.markdown(fromHTML: "<h6>Six</h6>") == "###### Six")
  }

  // MARK: - Inline formatting

  @Test("Paragraph preserves inline formatting")
  internal func paragraphPreservesInlineFormatting() throws {
    let html = """
      <p>foo <a href="https://example.com">bar</a> \
      <strong>baz</strong> <em>qux</em> <code>zap</code></p>
      """
    let markdown = try sut.markdown(fromHTML: html)

    // Regression: nested inline elements used to be flattened to plain text.
    #expect(markdown.contains("[bar](https://example.com)"))
    #expect(markdown.contains("**baz**"))
    #expect(markdown.contains("*qux*"))
    #expect(markdown.contains("`zap`"))
    #expect(markdown.contains("foo"))
  }

  // MARK: - Lists

  @Test("Unordered list")
  internal func unorderedList() throws {
    let markdown = try sut.markdown(fromHTML: "<ul><li>one</li><li>two</li></ul>")
    #expect(markdown.contains("- one"))
    #expect(markdown.contains("- two"))
  }

  @Test("Ordered list")
  internal func orderedList() throws {
    let markdown = try sut.markdown(fromHTML: "<ol><li>one</li><li>two</li></ol>")
    // swift-markdown's formatter emits "1." for each item (CommonMark
    // auto-increments ordered markers on render).
    #expect(markdown.contains("1. one"))
    #expect(markdown.contains("two"))
    #expect(!markdown.contains("- one"))
  }

  // MARK: - Block quotes, rules, images

  @Test("Block quote")
  internal func blockQuote() throws {
    let markdown = try sut.markdown(fromHTML: "<blockquote><p>quoted</p></blockquote>")
    #expect(markdown.contains("> quoted"))
  }

  @Test("Thematic break")
  internal func thematicBreak() throws {
    let markdown = try sut.markdown(fromHTML: "<p>a</p><hr><p>b</p>")
    #expect(markdown.contains("---"))
  }

  @Test("Block image")
  internal func blockImage() throws {
    let markdown = try sut.markdown(
      fromHTML: "<img src=\"image.png\" alt=\"An image\">"
    )
    #expect(markdown == "![An image](image.png)")
  }

  // MARK: - Code blocks

  @Test("Code block language from class")
  internal func codeBlockLanguageFromClass() throws {
    let html = "<pre><code class=\"language-swift\">let x = 1</code></pre>"
    let markdown = try sut.markdown(fromHTML: html)
    // Regression: language used to be hardcoded to "swift" regardless of input.
    #expect(markdown.contains("```swift"))
    #expect(markdown.contains("let x = 1"))
  }

  @Test("Code block without language")
  internal func codeBlockWithoutLanguage() throws {
    let markdown = try sut.markdown(fromHTML: "<pre><code>plain text</code></pre>")
    #expect(markdown.contains("plain text"))
    #expect(markdown.contains("```"))
    // No language identifier should be emitted on the opening fence.
    #expect(!markdown.contains("```swift"))
  }

  // MARK: - Definition lists

  @Test("Definition list renders terms and definitions")
  internal func definitionListRendersTermsAndDefinitions() throws {
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
    #expect(markdown.contains("**package.json**"))
    #expect(markdown.contains("for what node modules need to be installed"))
    #expect(markdown.contains("**Gruntfile.js**"))
    #expect(markdown.contains("the \"make\" file"))
  }

  @Test("Definition list preserves inline formatting in term")
  internal func definitionListPreservesInlineFormattingInTerm() throws {
    let html = """
      <dl>
        <dt><a href="http://nodejs.org/">NodeJS</a></dt>
        <dd>for building the project</dd>
      </dl>
      """
    let markdown = try sut.markdown(fromHTML: html)
    #expect(markdown.contains("[NodeJS](http://nodejs.org/)"))
    #expect(markdown.contains("for building the project"))
  }

  @Test("Definition list preserves nested block in definition")
  internal func definitionListPreservesNestedBlockInDefinition() throws {
    let html = """
      <dl>
        <dt>Grunt</dt>
        <dd>install grunt globally
          <pre><code class="language-bash">npm -g install grunt</code></pre>
        </dd>
      </dl>
      """
    let markdown = try sut.markdown(fromHTML: html)
    #expect(markdown.contains("**Grunt**"))
    #expect(markdown.contains("install grunt globally"))
    // The nested code block inside the <dd> must survive.
    #expect(markdown.contains("npm -g install grunt"))
    #expect(markdown.contains("```bash"))
  }

  // MARK: - Tables

  @Test("Layout table flattens cell content")
  internal func layoutTableFlattensCellContent() throws {
    // Mailchimp newsletters wrap nearly all body content in layout tables.
    let html = """
      <table><tbody>
        <tr><td><p>First cell</p></td></tr>
        <tr><td><p>Second cell</p></td></tr>
      </tbody></table>
      """
    let markdown = try sut.markdown(fromHTML: html)
    // Regression: <table> used to be dropped, erasing the whole newsletter body.
    #expect(markdown.contains("First cell"))
    #expect(markdown.contains("Second cell"))
  }

  @Test("Table preserves inline formatting and links")
  internal func tablePreservesInlineFormattingAndLinks() throws {
    let html = """
      <table><tr><td><p>see <a href="https://example.com">the docs</a></p></td></tr></table>
      """
    let markdown = try sut.markdown(fromHTML: html)
    #expect(markdown.contains("[the docs](https://example.com)"))
  }

  @Test("Nested table content emitted exactly once")
  internal func nestedTableContentEmittedExactlyOnce() throws {
    let html = """
      <table><tr><td>
        <table><tr><td><p>inner only</p></td></tr></table>
      </td></tr></table>
      """
    let markdown = try sut.markdown(fromHTML: html)
    let occurrences = markdown.components(separatedBy: "inner only").count - 1
    // Regression guard: descendant-cell selection must not double-emit nested
    // table content.
    #expect(occurrences == 1)
  }

  // MARK: - Stripped / empty content

  @Test("Script and iframe are stripped")
  internal func scriptAndIframeAreStripped() throws {
    let html = "<p>keep</p><script>evil()</script><iframe src=\"x\"></iframe>"
    let markdown = try sut.markdown(fromHTML: html)
    #expect(markdown.contains("keep"))
    #expect(!markdown.contains("evil"))
  }

  @Test("Empty input")
  internal func emptyInput() throws {
    #expect(try sut.markdown(fromHTML: "").isEmpty)
    #expect(try sut.markdown(fromHTML: "   ").isEmpty)
  }
}
