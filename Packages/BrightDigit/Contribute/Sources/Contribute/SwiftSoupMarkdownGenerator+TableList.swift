//
//  SwiftSoupMarkdownGenerator+TableList.swift
//  Contribute
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import Markdown
import SwiftSoup

extension SwiftSoupMarkdownGenerator {
  // MARK: - Definition lists

  /// Renders a `<dl>` as a sequence of paragraphs: each `<dt>` becomes a
  /// bold term, and each following `<dd>` contributes its own block content.
  ///
  /// swift-markdown has no definition-list node, so this mapping preserves the
  /// term/definition pairing in plain CommonMark (a `**term**` paragraph
  /// followed by the definition's blocks). It is intentionally lossy with
  /// respect to the semantic `<dl>` structure but loses no textual content,
  /// which the previously dropped behaviour did not guarantee.
  internal func definitionList(from element: SwiftSoup.Element) throws -> [any BlockMarkup] {
    var blocks: [any BlockMarkup] = []
    for child in childElements(of: element) {
      switch child.tagName() {
      case "dt":
        try term(of: child).map { blocks.append($0) }
      case "dd":
        blocks.append(contentsOf: try cellBlocks(of: child))
      default:
        break
      }
    }
    return blocks
  }

  /// Renders a `<dt>` as a bold-term paragraph, or `nil` when it is empty.
  ///
  /// The term is only emboldened when every inline child can nest inside a
  /// `Strong` (swift-markdown forbids `Link`/`Image` there). When it cannot —
  /// e.g. a term that is itself a link — the inline content is emitted verbatim
  /// so that no content is lost.
  private func term(of element: SwiftSoup.Element) throws -> Paragraph? {
    let inline = try inlineChildren(of: element)
    guard !inline.isEmpty else {
      return nil
    }
    let recurring = inline.compactMap { $0 as? any RecurringInlineMarkup }
    if recurring.count == inline.count {
      return Paragraph([Strong(recurring)])
    }
    return Paragraph(inline)
  }

  // MARK: - Tables

  /// Renders a `<table>` by extracting the block content of every cell in
  /// document order.
  ///
  /// Our real imported content (notably Mailchimp newsletters) uses tables
  /// purely for layout, with no header rows, so emitting a GFM data table
  /// would produce malformed output. Flattening cell content preserves the
  /// body — which the previously dropped behaviour discarded entirely — while
  /// staying valid CommonMark. Genuine data tables (with `<th>`) are not part
  /// of our content and are not specially handled.
  internal func tableBlocks(from element: SwiftSoup.Element) throws -> [any BlockMarkup] {
    var blocks: [any BlockMarkup] = []
    for cell in ownCells(of: element) {
      blocks.append(contentsOf: try cellBlocks(of: cell))
    }
    return blocks
  }

  /// The `<td>`/`<th>` cells belonging directly to `table` (not to any nested
  /// table), in document order. Nested tables are reached through
  /// ``cellBlocks(of:)`` recursion, so collecting all descendant cells here
  /// would emit nested content twice.
  private func ownCells(of table: SwiftSoup.Element) -> [SwiftSoup.Element] {
    var cells: [SwiftSoup.Element] = []
    for row in rows(of: table) {
      for cell in childElements(of: row)
      where cell.tagName() == "td" || cell.tagName() == "th" {
        cells.append(cell)
      }
    }
    return cells
  }

  /// The `<tr>` rows belonging directly to `table`, descending through an
  /// optional `<thead>`/`<tbody>`/`<tfoot>` wrapper but not into nested tables.
  private func rows(of table: SwiftSoup.Element) -> [SwiftSoup.Element] {
    var rows: [SwiftSoup.Element] = []
    for child in childElements(of: table) {
      switch child.tagName() {
      case "tr":
        rows.append(child)
      case "thead", "tbody", "tfoot":
        rows.append(contentsOf: childElements(of: child, named: "tr"))
      default:
        break
      }
    }
    return rows
  }

  /// Renders the content of a container cell (`<dd>`, `<td>`, `<th>`):
  /// leading inline content as a paragraph, then any nested block children.
  private func cellBlocks(of element: SwiftSoup.Element) throws -> [any BlockMarkup] {
    var blocks: [any BlockMarkup] = []
    let inline = try inlineChildren(of: element)
    if !inline.isEmpty {
      blocks.append(Paragraph(inline))
    }
    for child in childElements(of: element)
    where Self.blockLevelTags.contains(child.tagName()) {
      blocks.append(contentsOf: try blockMarkup(for: child))
    }
    return blocks
  }
}
