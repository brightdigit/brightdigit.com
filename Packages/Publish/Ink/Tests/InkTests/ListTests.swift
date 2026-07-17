/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Ink
import XCTest

internal final class ListTests: XCTestCase {
  internal func testOrderedList() {
    let html = MarkdownParser().html(
      from: """
        1. One
        2. Two
        """
    )

    XCTAssertEqual(html, #"<ol><li>One</li><li>Two</li></ol>"#)
  }

  internal func test10DigitOrderedList() {
    let html = MarkdownParser().html(
      from: """
        1234567890. Not a list
        """
    )

    XCTAssertEqual(html, "<p>1234567890. Not a list</p>")
  }

  internal func testOrderedListParentheses() {
    let html = MarkdownParser().html(
      from: """
        1) One
        2) Two
        """
    )

    XCTAssertEqual(html, #"<ol><li>One</li><li>Two</li></ol>"#)
  }

  internal func testOrderedListWithoutIncrementedNumbers() {
    let html = MarkdownParser().html(
      from: """
        1. One
        3. Two
        17. Three
        """
    )

    XCTAssertEqual(html, "<ol><li>One</li><li>Two</li><li>Three</li></ol>")
  }

  internal func testOrderedListWithInvalidNumbers() {
    let html = MarkdownParser().html(
      from: """
        1. One
        3!. Two
        17. Three
        """
    )

    XCTAssertEqual(html, "<ol><li>One 3!. Two</li><li>Three</li></ol>")
  }

  internal func testUnorderedList() {
    let html = MarkdownParser().html(
      from: """
        - One
        - Two
        - Three
        """
    )

    XCTAssertEqual(html, "<ul><li>One</li><li>Two</li><li>Three</li></ul>")
  }

  internal func testMixedUnorderedList() {
    let html = MarkdownParser().html(
      from: """
        - One
        * Two
        * Three
        - Four
        """
    )

    XCTAssertEqual(
      html, "<ul><li>One</li></ul><ul><li>Two</li><li>Three</li></ul><ul><li>Four</li></ul>"
    )
  }

  internal func testMixedList() {
    let html = MarkdownParser().html(
      from: """
        1. One
        2. Two
        3) Three
        * Four
        """
    )

    XCTAssertEqual(
      html,
      #"<ol><li>One</li><li>Two</li></ol><ol start="3"><li>Three</li></ol><ul><li>Four</li></ul>"#
    )
  }

  internal func testUnorderedListWithMultiLineItem() {
    let html = MarkdownParser().html(
      from: """
        - One
        Some text
        - Two
        """
    )

    XCTAssertEqual(html, "<ul><li>One Some text</li><li>Two</li></ul>")
  }

  // The nested / indented list fixtures below embed 4-space-indented markup inside
  // string literals, which the multiline-string indentation check misreads.
  // swiftlint:disable indentation_width
  internal func testUnorderedListWithNestedList() {
    let html = MarkdownParser().html(
      from: """
        - A
        - B
            - B1
                - B11
            - B2
        """
    )

    let expectedComponents: [String] = [
      "<ul>",
      "<li>A</li>",
      "<li>B",
      "<ul>",
      "<li>B1",
      "<ul>",
      "<li>B11</li>",
      "</ul>",
      "</li>",
      "<li>B2</li>",
      "</ul>",
      "</li>",
      "</ul>",
    ]

    XCTAssertEqual(html, expectedComponents.joined())
  }

  internal func testUnorderedListWithInvalidMarker() {
    let html = MarkdownParser().html(
      from: """
        - One
        -Two
        - Three
        """
    )

    XCTAssertEqual(html, "<ul><li>One -Two</li><li>Three</li></ul>")
  }

  internal func testOrderedIndentedList() {
    let html = MarkdownParser().html(
      from: """
          1. One
          2. Two
        """
    )

    XCTAssertEqual(html, #"<ol><li>One</li><li>Two</li></ol>"#)
  }

  internal func testUnorderedIndentedList() {
    let html = MarkdownParser().html(
      from: """
          - One
          - Two
          - Three
        """
    )

    XCTAssertEqual(html, "<ul><li>One</li><li>Two</li><li>Three</li></ul>")
  }
  // swiftlint:enable indentation_width
}

extension ListTests {
  internal static var allTests: Linux.TestList<ListTests> {
    [
      ("testOrderedList", testOrderedList),
      ("test10DigitOrderedList", test10DigitOrderedList),
      ("testOrderedListParentheses", testOrderedListParentheses),
      ("testOrderedListWithoutIncrementedNumbers", testOrderedListWithoutIncrementedNumbers),
      ("testOrderedListWithInvalidNumbers", testOrderedListWithInvalidNumbers),
      ("testUnorderedList", testUnorderedList),
      ("testMixedUnorderedList", testMixedUnorderedList),
      ("testMixedList", testMixedList),
      ("testUnorderedListWithMultiLineItem", testUnorderedListWithMultiLineItem),
      ("testUnorderedListWithNestedList", testUnorderedListWithNestedList),
      ("testUnorderedListWithInvalidMarker", testUnorderedListWithInvalidMarker),
      ("testOrderedIndentedList", testUnorderedIndentedList),
      ("testUnorderedIndentedList", testUnorderedIndentedList),
    ]
  }
}
