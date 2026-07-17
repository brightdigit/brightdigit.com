/**
*  Ink
*  Copyright (c) John Sundell 2020
*  MIT license, see LICENSE file for details
*/

import Ink
import XCTest

extension TableTests {
  internal func testTableWithInternalMarkdown() {
    let html = MarkdownParser().html(
      from: """
        | Table  | Header     | [Link](/uri) |
        | ------ | ---------- | ------------ |
        | Some   | *emphasis* | and          |
        | `code` | in         | table        |
        """
    )

    XCTAssertEqual(
      html,
      """
      <table>\
      <thead>\
      <tr><th>Table</th><th>Header</th><th><a href="/uri">Link</a></th></tr>\
      </thead>\
      <tbody>\
      <tr><td>Some</td><td><em>emphasis</em></td><td>and</td></tr>\
      <tr><td><code>code</code></td><td>in</td><td>table</td></tr>\
      </tbody>\
      </table>
      """
    )
  }

  internal func testTableWithAlignment() {
    let html = MarkdownParser().html(
      from: """
        | Left | Center | Right |
        | :- | :-: | -:|
        | One | Two | Three |
        """
    )

    XCTAssertEqual(
      html,
      """
      <table>\
      <thead><tr>\
      <th align="left">Left</th><th align="center">Center</th><th align="right">Right</th>\
      </tr></thead>\
      <tbody>\
      <tr><td align="left">One</td><td align="center">Two</td><td align="right">Three</td></tr>\
      </tbody>\
      </table>
      """
    )
  }

  internal func testMissingPipeEndsTable() {
    let html = MarkdownParser().html(
      from: """
        | HeaderA | HeaderB |
        | ------- | ------- |
        | CellA   | CellB   |
        > Quote
        """
    )

    XCTAssertEqual(
      html,
      """
      <table>\
      <thead><tr><th>HeaderA</th><th>HeaderB</th></tr></thead>\
      <tbody><tr><td>CellA</td><td>CellB</td></tr></tbody>\
      </table>\
      <blockquote><p>Quote</p></blockquote>
      """
    )
  }

  // #40: the delimiter row's column count must match the header's in GFM; a 1-column
  // delimiter under a 2-column header disqualifies the table, so it is a paragraph. Ink
  // accepted the mismatch and rendered a header-less table.
  internal func testHeaderNotParsedForColumnCountMismatch() {
    let html = MarkdownParser().html(
      from: """
        | HeaderA | HeaderB |
        | ------- |
        | CellA   | CellB |
        """
    )

    XCTAssertEqual(html, "<p>| HeaderA | HeaderB | | ------- | | CellA   | CellB |</p>")
  }
}

extension TableTests {
  internal static var allTests: Linux.TestList<TableTests> {
    [
      ("testTableWithoutHeader", testTableWithoutHeader),
      ("testTableWithHeader", testTableWithHeader),
      ("testTableWithUnalignedColumns", testTableWithUnalignedColumns),
      ("testTableWithOnlyHeader", testTableWithOnlyHeader),
      ("testIncompleteTable", testIncompleteTable),
      ("testInvalidTable", testInvalidTable),
      ("testTableBetweenParagraphs", testTableBetweenParagraphs),
      ("testTableWithUnevenColumns", testTableWithUnevenColumns),
      ("testTableWithInternalMarkdown", testTableWithInternalMarkdown),
      ("testTableWithAlignment", testTableWithAlignment),
      ("testMissingPipeEndsTable", testMissingPipeEndsTable),
      ("testHeaderNotParsedForColumnCountMismatch", testHeaderNotParsedForColumnCountMismatch),
    ]
  }
}
