/**
*  Ink
*  Copyright (c) John Sundell 2020
*  MIT license, see LICENSE file for details
*/

import Ink
import XCTest

internal final class TableTests: XCTestCase {
  // #40: GFM requires a delimiter row (`| --- |`) to recognise a table. Without one this
  // is just a paragraph of pipe-separated text. Ink parsed header-less tables; GFM/swift-
  // markdown does not, so the content renders as a literal paragraph.
  internal func testTableWithoutHeader() {
    let html = MarkdownParser().html(
      from: """
        | HeaderA | HeaderB |
        | CellA   | CellB   |
        """
    )

    XCTAssertEqual(html, "<p>| HeaderA | HeaderB | | CellA   | CellB   |</p>")
  }

  internal func testTableWithHeader() {
    let html = MarkdownParser().html(
      from: """
        | HeaderA | HeaderB | HeaderC |
        | ------- | ------- | ------- |
        | CellA1  | CellB1  | CellC1  |
        | CellA2  | CellB2  | CellC2  |
        """
    )

    XCTAssertEqual(
      html,
      """
      <table>\
      <thead><tr><th>HeaderA</th><th>HeaderB</th><th>HeaderC</th></tr></thead>\
      <tbody>\
      <tr><td>CellA1</td><td>CellB1</td><td>CellC1</td></tr>\
      <tr><td>CellA2</td><td>CellB2</td><td>CellC2</td></tr>\
      </tbody>\
      </table>
      """
    )
  }

  internal func testTableWithUnalignedColumns() {
    let html = MarkdownParser().html(
      from: """
        | HeaderA                        | HeaderB    | HeaderC |
        | ------------------------------ | ----------- | ------------ |
        | CellA1                    | CellB1      | CellC1       |
        | CellA2                   | CellB2       | CellC2        |
        """
    )

    XCTAssertEqual(
      html,
      """
      <table>\
      <thead><tr><th>HeaderA</th><th>HeaderB</th><th>HeaderC</th></tr></thead>\
      <tbody>\
      <tr><td>CellA1</td><td>CellB1</td><td>CellC1</td></tr>\
      <tr><td>CellA2</td><td>CellB2</td><td>CellC2</td></tr>\
      </tbody>\
      </table>
      """
    )
  }

  internal func testTableWithOnlyHeader() {
    let html = MarkdownParser().html(
      from: """
        | HeaderA   | HeaderB   | HeaderC |
        | ----------| ----------| ------- |
        """
    )

    XCTAssertEqual(
      html,
      """
      <table>\
      <thead><tr><th>HeaderA</th><th>HeaderB</th><th>HeaderC</th></tr></thead>\
      </table>
      """
    )
  }

  internal func testIncompleteTable() {
    let html = MarkdownParser().html(
      from: """
        | one | two |
        | three |
        | four | five | six
        """
    )

    XCTAssertEqual(html, "<p>| one | two | | three | | four | five | six</p>")
  }

  internal func testInvalidTable() {
    let html = MarkdownParser().html(
      from: """
        |123 Not a table
        """
    )

    XCTAssertEqual(html, "<p>|123 Not a table</p>")
  }

  internal func testTableBetweenParagraphs() {
    let html = MarkdownParser().html(
      from: """
        A paragraph.

        | A | B |
        | C | D |

        Another paragraph.
        """
    )

    // #40: no delimiter row, so GFM treats the pipe lines as a paragraph.
    XCTAssertEqual(
      html,
      """
      <p>A paragraph.</p>\
      <p>| A | B | | C | D |</p>\
      <p>Another paragraph.</p>
      """
    )
  }

  internal func testTableWithUnevenColumns() {
    let html = MarkdownParser().html(
      from: """
        | one | two |
        | three | four | five |

        | one | two |
        | three |
        """
    )

    // #40: neither pipe block has a delimiter row, so both render as paragraphs. The
    // source fixture contains non-breaking spaces (U+00A0) between `four`/`five`/`six`;
    // GFM-as-paragraph preserves them verbatim (Ink's table parser had split on them).
    XCTAssertEqual(
      html,
      """
      <p>| one | two | | three |\u{00A0}four |\u{00A0}five |</p>\
      <p>| one | two | | three |</p>
      """
    )
  }
}
