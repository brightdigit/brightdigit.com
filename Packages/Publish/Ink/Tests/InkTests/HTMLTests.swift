/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Ink
import XCTest

internal final class HTMLTests: XCTestCase {
  // The HTML fixtures below embed 4-space-indented markup inside string literals,
  // which the multiline-string indentation check misreads.
  // swiftlint:disable indentation_width
  internal func testTopLevelHTML() {
    let html = MarkdownParser().html(
      from: """
        Hello

        <div>
            <span class="text">Whole wide</span>
        </div>

        World
        """
    )

    XCTAssertEqual(
      html,
      """
      <p>Hello</p><div>
          <span class="text">Whole wide</span>
      </div><p>World</p>
      """
    )
  }

  internal func testNestedTopLevelHTML() {
    let html = MarkdownParser().html(
      from: """
        <div>
            <div>Hello</div>
            <div>World</div>
        </div>
        """
    )

    XCTAssertEqual(
      html,
      """
      <div>
          <div>Hello</div>
          <div>World</div>
      </div>
      """
    )
  }
  // swiftlint:enable indentation_width

  internal func testTopLevelHTMLWithPreviousNewline() {
    let html = MarkdownParser().html(from: "Text\n<h2>Heading</h2>")
    XCTAssertEqual(html, "<p>Text</p><h2>Heading</h2>")
  }

  internal func testIgnoringFormattingWithinTopLevelHTML() {
    let html = MarkdownParser().html(from: "<div>_Hello_</div>")
    XCTAssertEqual(html, "<div>_Hello_</div>")
  }

  // #40: CommonMark does not suppress emphasis inside inline HTML, so `_World_` between
  // `<span>` tags is parsed as emphasis. Ink's parser left it verbatim.
  internal func testIgnoringTextFormattingWithinInlineHTML() {
    let html = MarkdownParser().html(from: "Hello <span>_World_</span>")
    XCTAssertEqual(html, "<p>Hello <span><em>World</em></span></p>")
  }

  internal func testIgnoringListsWithinInlineHTML() {
    let html = MarkdownParser().html(from: "<h2>1. Hello</h2><h2>- World</h2>")
    XCTAssertEqual(html, "<h2>1. Hello</h2><h2>- World</h2>")
  }

  // #40: an inline `<p>` tag inside running text is treated as inline HTML by
  // CommonMark (it does not break the paragraph). Ink split the paragraph at it.
  internal func testInlineParagraphTagEndingCurrentParagraph() {
    let html = MarkdownParser().html(from: "One <p>Two</p> Three")
    XCTAssertEqual(html, "<p>One <p>Two</p> Three</p>")
  }

  internal func testTopLevelSelfClosingHTMLElement() {
    let html = MarkdownParser().html(
      from: """
        Hello

        <img src="image.png"/>

        World
        """
    )

    XCTAssertEqual(html, #"<p>Hello</p><img src="image.png"/><p>World</p>"#)
  }

  internal func testInlineSelfClosingHTMLElement() {
    let html = MarkdownParser().html(from: #"Hello <img src="image.png"/> World"#)
    XCTAssertEqual(html, #"<p>Hello <img src="image.png"/> World</p>"#)
  }

  // #40: a `<br/>` on its own line between two text lines is inline HTML inside a single
  // paragraph under CommonMark (lines join with soft breaks). Ink split it into three blocks.
  internal func testTopLevelHTMLLineBreak() {
    let html = MarkdownParser().html(
      from: """
        Hello
        <br/>
        World
        """
    )

    XCTAssertEqual(html, "<p>Hello <br/> World</p>")
  }

  internal func testHTMLComment() {
    let html = MarkdownParser().html(
      from: """
        Hello
        <!-- Comment -->
        World
        """
    )

    XCTAssertEqual(html, "<p>Hello</p><!-- Comment --><p>World</p>")
  }

  internal func testHTMLEntities() {
    let html = MarkdownParser().html(
      from: """
        Hello &amp; welcome to &lt;Ink&gt;
        """
    )

    XCTAssertEqual(html, "<p>Hello &amp; welcome to &lt;Ink&gt;</p>")
  }
}

extension HTMLTests {
  internal static var allTests: Linux.TestList<HTMLTests> {
    [
      ("testTopLevelHTML", testTopLevelHTML),
      ("testNestedTopLevelHTML", testNestedTopLevelHTML),
      ("testTopLevelHTMLWithPreviousNewline", testTopLevelHTMLWithPreviousNewline),
      ("testIgnoringFormattingWithinTopLevelHTML", testIgnoringFormattingWithinTopLevelHTML),
      ("testIgnoringTextFormattingWithinInlineHTML", testIgnoringTextFormattingWithinInlineHTML),
      ("testIgnoringListsWithinInlineHTML", testIgnoringListsWithinInlineHTML),
      (
        "testInlineParagraphTagEndingCurrentParagraph", testInlineParagraphTagEndingCurrentParagraph
      ),
      ("testTopLevelSelfClosingHTMLElement", testTopLevelSelfClosingHTMLElement),
      ("testInlineSelfClosingHTMLElement", testInlineSelfClosingHTMLElement),
      ("testTopLevelHTMLLineBreak", testTopLevelHTMLLineBreak),
      ("testHTMLComment", testHTMLComment),
      ("testHTMLEntities", testHTMLEntities),
    ]
  }
}
