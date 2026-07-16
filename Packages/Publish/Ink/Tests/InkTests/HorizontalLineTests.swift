/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Ink
import XCTest

internal final class HorizontalLineTests: XCTestCase {
  internal func testHorizonalLineWithDashes() {
    let html = MarkdownParser().html(
      from: """
        Hello

        ---

        World
        """
    )

    XCTAssertEqual(html, "<p>Hello</p><hr><p>World</p>")
  }

  internal func testHorizontalLineWithDashesAtTheStartOfString() {
    let html = MarkdownParser().html(from: "---\nHello")
    XCTAssertEqual(html, "<hr><p>Hello</p>")
  }

  internal func testHorizontalLineWithAsterisks() {
    let html = MarkdownParser().html(
      from: """
        Hello

        ***

        World
        """
    )

    XCTAssertEqual(html, "<p>Hello</p><hr><p>World</p>")
  }
}

extension HorizontalLineTests {
  internal static var allTests: Linux.TestList<HorizontalLineTests> {
    [
      ("testHorizonalLineWithDashes", testHorizonalLineWithDashes),
      (
        "testHorizontalLineWithDashesAtTheStartOfString",
        testHorizontalLineWithDashesAtTheStartOfString
      ),
      ("testHorizontalLineWithAsterisks", testHorizontalLineWithAsterisks),
    ]
  }
}
