/**
 *  Ink
 *  Copyright (c) John Sundell 2020
 *  MIT license, see LICENSE file for details
 */

import XCTest
import Ink

final class TableTests: XCTestCase {
    // #40: GFM requires a delimiter row (`| --- |`) to recognise a table. Without one this
    // is just a paragraph of pipe-separated text. Ink parsed header-less tables; GFM/swift-
    // markdown does not, so the content renders as a literal paragraph.
    func testTableWithoutHeader() {
        let html = MarkdownParser().html(from: """
        | HeaderA | HeaderB |
        | CellA   | CellB   |
        """)

        XCTAssertEqual(html, "<p>| HeaderA | HeaderB | | CellA   | CellB   |</p>")
    }

    func testTableWithHeader() {
        let html = MarkdownParser().html(from: """
        | HeaderA | HeaderB | HeaderC |
        | ------- | ------- | ------- |
        | CellA1  | CellB1  | CellC1  |
        | CellA2  | CellB2  | CellC2  |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr><th>HeaderA</th><th>HeaderB</th><th>HeaderC</th></tr></thead>\
        <tbody>\
        <tr><td>CellA1</td><td>CellB1</td><td>CellC1</td></tr>\
        <tr><td>CellA2</td><td>CellB2</td><td>CellC2</td></tr>\
        </tbody>\
        </table>
        """)
    }

    func testTableWithUnalignedColumns() {
        let html = MarkdownParser().html(from: """
        | HeaderA                        | HeaderB    | HeaderC |
        | ------------------------------ | ----------- | ------------ |
        | CellA1                    | CellB1      | CellC1       |
        | CellA2                   | CellB2       | CellC2        |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr><th>HeaderA</th><th>HeaderB</th><th>HeaderC</th></tr></thead>\
        <tbody>\
        <tr><td>CellA1</td><td>CellB1</td><td>CellC1</td></tr>\
        <tr><td>CellA2</td><td>CellB2</td><td>CellC2</td></tr>\
        </tbody>\
        </table>
        """)
    }

    func testTableWithOnlyHeader() {
        let html = MarkdownParser().html(from: """
        | HeaderA   | HeaderB   | HeaderC |
        | ----------| ----------| ------- |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr><th>HeaderA</th><th>HeaderB</th><th>HeaderC</th></tr></thead>\
        </table>
        """)
    }

    func testIncompleteTable() {
        let html = MarkdownParser().html(from: """
        | one | two |
        | three |
        | four | five | six
        """)

        XCTAssertEqual(html, "<p>| one | two | | three | | four | five | six</p>")
    }

    func testInvalidTable() {
        let html = MarkdownParser().html(from: """
        |123 Not a table
        """)

        XCTAssertEqual(html, "<p>|123 Not a table</p>")
    }

    func testTableBetweenParagraphs() {
        let html = MarkdownParser().html(from: """
        A paragraph.

        | A | B |
        | C | D |

        Another paragraph.
        """)

        // #40: no delimiter row, so GFM treats the pipe lines as a paragraph.
        XCTAssertEqual(html, """
        <p>A paragraph.</p>\
        <p>| A | B | | C | D |</p>\
        <p>Another paragraph.</p>
        """)
    }

    func testTableWithUnevenColumns() {
        let html = MarkdownParser().html(from: """
        | one | two |
        | three | four | five |

        | one | two |
        | three |
        """)

        // #40: neither pipe block has a delimiter row, so both render as paragraphs. The
        // source fixture contains non-breaking spaces (U+00A0) between `four`/`five`/`six`;
        // GFM-as-paragraph preserves them verbatim (Ink's table parser had split on them).
        XCTAssertEqual(html, """
        <p>| one | two | | three |\u{00A0}four |\u{00A0}five |</p>\
        <p>| one | two | | three |</p>
        """)
    }

    func testTableWithInternalMarkdown() {
        let html = MarkdownParser().html(from: """
        | Table  | Header     | [Link](/uri) |
        | ------ | ---------- | ------------ |
        | Some   | *emphasis* | and          |
        | `code` | in         | table        |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead>\
        <tr><th>Table</th><th>Header</th><th><a href="/uri">Link</a></th></tr>\
        </thead>\
        <tbody>\
        <tr><td>Some</td><td><em>emphasis</em></td><td>and</td></tr>\
        <tr><td><code>code</code></td><td>in</td><td>table</td></tr>\
        </tbody>\
        </table>
        """)
    }

    func testTableWithAlignment() {
        let html = MarkdownParser().html(from: """
        | Left | Center | Right |
        | :- | :-: | -:|
        | One | Two | Three |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr>\
        <th align="left">Left</th><th align="center">Center</th><th align="right">Right</th>\
        </tr></thead>\
        <tbody>\
        <tr><td align="left">One</td><td align="center">Two</td><td align="right">Three</td></tr>\
        </tbody>\
        </table>
        """)
    }

    func testMissingPipeEndsTable() {
        let html = MarkdownParser().html(from: """
        | HeaderA | HeaderB |
        | ------- | ------- |
        | CellA   | CellB   |
        > Quote
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr><th>HeaderA</th><th>HeaderB</th></tr></thead>\
        <tbody><tr><td>CellA</td><td>CellB</td></tr></tbody>\
        </table>\
        <blockquote><p>Quote</p></blockquote>
        """)
    }

    // #40: the delimiter row's column count must match the header's in GFM; a 1-column
    // delimiter under a 2-column header disqualifies the table, so it is a paragraph. Ink
    // accepted the mismatch and rendered a header-less table.
    func testHeaderNotParsedForColumnCountMismatch() {
        let html = MarkdownParser().html(from: """
        | HeaderA | HeaderB |
        | ------- |
        | CellA   | CellB |
        """)

        XCTAssertEqual(html, "<p>| HeaderA | HeaderB | | ------- | | CellA   | CellB |</p>")
    }
}

extension TableTests {
    static var allTests: Linux.TestList<TableTests> {
        return [
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
