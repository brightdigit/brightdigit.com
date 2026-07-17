/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Ink
import XCTest

internal final class TextFormattingTests: XCTestCase {
  internal func testParagraph() {
    let html = MarkdownParser().html(from: "Hello, world!")
    XCTAssertEqual(html, "<p>Hello, world!</p>")
  }

  internal func testParagraphs() {
    let html = MarkdownParser().html(from: "Hello, world!\n\nAgain.")
    XCTAssertEqual(html, "<p>Hello, world!</p><p>Again.</p>")
  }

  internal func testDosParagraphs() {
    let html = MarkdownParser().html(from: "Hello, world!\r\n\r\nAgain.")
    XCTAssertEqual(html, "<p>Hello, world!</p><p>Again.</p>")
  }

  internal func testItalicText() {
    let html = MarkdownParser().html(from: "Hello, *world*!")
    XCTAssertEqual(html, "<p>Hello, <em>world</em>!</p>")
  }

  internal func testBoldText() {
    let html = MarkdownParser().html(from: "Hello, **world**!")
    XCTAssertEqual(html, "<p>Hello, <strong>world</strong>!</p>")
  }

  // #40: CommonMark's emphasis algorithm nests `<em>` outside `<strong>` for `***x***`;
  // Ink nested them the other way around.
  internal func testItalicBoldText() {
    let html = MarkdownParser().html(from: "Hello, ***world***!")
    XCTAssertEqual(html, "<p>Hello, <em><strong>world</strong></em>!</p>")
  }

  internal func testItalicBoldTextWithSeparateStartMarkers() {
    let html = MarkdownParser().html(from: "**Hello, *world***!")
    XCTAssertEqual(html, "<p><strong>Hello, <em>world</em></strong>!</p>")
  }

  internal func testItalicTextWithinBoldText() {
    let html = MarkdownParser().html(from: "**Hello, *world*!**")
    XCTAssertEqual(html, "<p><strong>Hello, <em>world</em>!</strong></p>")
  }

  internal func testBoldTextWithinItalicText() {
    let html = MarkdownParser().html(from: "*Hello, **world**!*")
    XCTAssertEqual(html, "<p><em>Hello, <strong>world</strong>!</em></p>")
  }

  internal func testItalicTextWithExtraLeadingMarkers() {
    let html = MarkdownParser().html(from: "**Hello*")
    XCTAssertEqual(html, "<p>*<em>Hello</em></p>")
  }

  // #40: CommonMark leaves the unmatched leading `*` as a literal before the `<strong>`.
  internal func testBoldTextWithExtraLeadingMarkers() {
    let html = MarkdownParser().html(from: "***Hello**")
    XCTAssertEqual(html, "<p>*<strong>Hello</strong></p>")
  }

  internal func testItalicTextWithExtraTrailingMarkers() {
    let html = MarkdownParser().html(from: "*Hello**")
    XCTAssertEqual(html, "<p><em>Hello</em>*</p>")
  }

  internal func testBoldTextWithExtraTrailingMarkers() {
    let html = MarkdownParser().html(from: "**Hello***")
    XCTAssertEqual(html, "<p><strong>Hello</strong>*</p>")
  }

  internal func testItalicBoldTextWithExtraTrailingMarkers() {
    let html = MarkdownParser().html(from: "**Hello, *world*****!")
    XCTAssertEqual(html, "<p><strong>Hello, <em>world</em></strong>**!</p>")
  }

  internal func testUnterminatedItalicMarker() {
    let html = MarkdownParser().html(from: "*Hello")
    XCTAssertEqual(html, "<p>*Hello</p>")
  }

  internal func testUnterminatedBoldMarker() {
    let html = MarkdownParser().html(from: "**Hello")
    XCTAssertEqual(html, "<p>**Hello</p>")
  }

  internal func testUnterminatedItalicBoldMarker() {
    let html = MarkdownParser().html(from: "***Hello")
    XCTAssertEqual(html, "<p>***Hello</p>")
  }

  // #40: CommonMark's emphasis-matching resolves these nested-unterminated cases
  // differently from Ink's hand-written marker scanner.
  internal func testUnterminatedItalicMarkerWithinBoldText() {
    let html = MarkdownParser().html(from: "**Hello, *world!**")
    XCTAssertEqual(html, "<p>*<em>Hello, <em>world!</em></em></p>")
  }

  internal func testUnterminatedBoldMarkerWithinItalicText() {
    let html = MarkdownParser().html(from: "*Hello, **world!*")
    XCTAssertEqual(html, "<p>*Hello, *<em>world!</em></p>")
  }

  internal func testStrikethroughText() {
    let html = MarkdownParser().html(from: "Hello, ~~world!~~")
    XCTAssertEqual(html, "<p>Hello, <s>world!</s></p>")
  }

  internal func testSingleTildeWithinStrikethroughText() {
    let html = MarkdownParser().html(from: "Hello, ~~wor~ld!~~")
    XCTAssertEqual(html, "<p>Hello, <s>wor~ld!</s></p>")
  }

  internal func testUnterminatedStrikethroughMarker() {
    let html = MarkdownParser().html(from: "~~Hello")
    XCTAssertEqual(html, "<p>~~Hello</p>")
  }

  internal func testEncodingSpecialCharacters() {
    let html = MarkdownParser().html(from: "Hello < World & >")
    XCTAssertEqual(html, "<p>Hello &lt; World &amp; &gt;</p>")
  }

  internal func testSingleLineBlockquote() {
    let html = MarkdownParser().html(from: "> Hello, world!")
    XCTAssertEqual(html, "<blockquote><p>Hello, world!</p></blockquote>")
  }

  internal func testMultiLineBlockquote() {
    let html = MarkdownParser().html(
      from: """
        > One
        > Two
        > Three
        """
    )

    XCTAssertEqual(html, "<blockquote><p>One Two Three</p></blockquote>")
  }

  internal func testEscapingSymbolsWithBackslash() {
    let html = MarkdownParser().html(
      from: """
        \\# Not a title
        \\*Not italic\\*
        """
    )

    XCTAssertEqual(html, "<p># Not a title *Not italic*</p>")
  }

  internal func testListAfterFormattedText() {
    let html = MarkdownParser().html(
      from: """
        This is a test
        - One
        - Two
        """
    )

    XCTAssertEqual(
      html,
      """
      <p>This is a test</p><ul><li>One</li><li>Two</li></ul>
      """
    )
  }

  internal func testDoubleSpacedHardLinebreak() {
    let html = MarkdownParser().html(from: "Line 1  \nLine 2")

    XCTAssertEqual(html, "<p>Line 1<br>Line 2</p>")
  }

  internal func testEscapedHardLinebreak() {
    let html = MarkdownParser().html(from: "Line 1\\\nLine 2")

    XCTAssertEqual(html, "<p>Line 1<br>Line 2</p>")
  }
}

extension TextFormattingTests {
  internal static var allTests: Linux.TestList<TextFormattingTests> {
    [
      ("testParagraph", testParagraph),
      ("testParagraphs", testParagraphs),
      ("testDosParagraphs", testDosParagraphs),
      ("testItalicText", testItalicText),
      ("testBoldText", testBoldText),
      ("testItalicBoldText", testItalicBoldText),
      ("testItalicBoldTextWithSeparateStartMarkers", testItalicBoldTextWithSeparateStartMarkers),
      ("testItalicTextWithinBoldText", testItalicTextWithinBoldText),
      ("testBoldTextWithinItalicText", testBoldTextWithinItalicText),
      ("testItalicTextWithExtraLeadingMarkers", testItalicTextWithExtraLeadingMarkers),
      ("testBoldTextWithExtraLeadingMarkers", testBoldTextWithExtraLeadingMarkers),
      ("testItalicTextWithExtraTrailingMarkers", testItalicTextWithExtraTrailingMarkers),
      ("testBoldTextWithExtraTrailingMarkers", testBoldTextWithExtraTrailingMarkers),
      ("testItalicBoldTextWithExtraTrailingMarkers", testItalicBoldTextWithExtraTrailingMarkers),
      ("testUnterminatedItalicMarker", testUnterminatedItalicMarker),
      ("testUnterminatedBoldMarker", testUnterminatedBoldMarker),
      ("testUnterminatedItalicBoldMarker", testUnterminatedItalicBoldMarker),
      ("testUnterminatedItalicMarkerWithinBoldText", testUnterminatedItalicMarkerWithinBoldText),
      ("testUnterminatedBoldMarkerWithinItalicText", testUnterminatedBoldMarkerWithinItalicText),
      ("testStrikethroughText", testStrikethroughText),
      ("testSingleTildeWithinStrikethroughText", testSingleTildeWithinStrikethroughText),
      ("testUnterminatedStrikethroughMarker", testUnterminatedStrikethroughMarker),
      ("testEncodingSpecialCharacters", testEncodingSpecialCharacters),
      ("testSingleLineBlockquote", testSingleLineBlockquote),
      ("testMultiLineBlockquote", testMultiLineBlockquote),
      ("testEscapingSymbolsWithBackslash", testEscapingSymbolsWithBackslash),
      ("testListAfterFormattedText", testListAfterFormattedText),
      ("testDoubleSpacedHardLinebreak", testDoubleSpacedHardLinebreak),
      ("testEscapedHardLinebreak", testEscapedHardLinebreak),
    ]
  }
}
