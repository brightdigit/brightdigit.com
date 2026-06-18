//
//  SwiftSoupMarkdownGenerator.swift
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

/// A ``MarkdownGenerator`` that converts HTML to Markdown entirely in-process
/// using [SwiftSoup](https://github.com/scinfu/SwiftSoup) for HTML parsing and
/// [swift-markdown](https://github.com/swiftlang/swift-markdown) for emission.
///
/// Unlike `PandocMarkdownGenerator` (removed), this requires no external
/// `pandoc` binary, making it portable across Linux and CI environments.
///
/// ## Coverage
/// The converter targets the common subset of post HTML (headings, paragraphs,
/// inline emphasis/links/code, lists, block quotes, images, code blocks).
///
/// `<dl>`/`<dt>`/`<dd>` and `<table>` are also handled, but lossily, because
/// CommonMark/swift-markdown have no node for either:
/// - A `<dl>` renders each `<dt>` as a bold-term paragraph followed by its
///   `<dd>` content, preserving the term/definition pairing as plain prose.
/// - A `<table>` is treated as layout (our only real-world use, e.g. Mailchimp
///   newsletters) and flattened to its cells' block content in document order.
///   This deliberately does **not** emit a GFM data table; genuine
///   `<th>`-headed data tables are not part of our content and are not
///   specially handled.
///
/// ## Known limitations
/// The converter does not aim for full Pandoc parity. It does not preserve
/// semantic `<dl>`/`<table>` structure (see Coverage), does not emit GFM data
/// tables, and `Link`/`Image` nested inside `<strong>`/`<em>`/`<a>` are dropped
/// because swift-markdown's inline type model cannot represent them.
///
/// Block and inline rendering lives in `SwiftSoupMarkdownGenerator+Markup.swift`.
public struct SwiftSoupMarkdownGenerator: MarkdownGenerator {
  /// Block-level tag names that must not be folded into inline content.
  internal static let blockLevelTags: Set<String> = [
    "h1", "h2", "h3", "h4", "h5", "h6",
    "p", "div", "ul", "ol", "li", "blockquote", "pre",
    "hr", "figure", "table", "dl", "section", "article",
    "header", "footer", "aside", "nav",
  ]

  /// Creates a new ``SwiftSoupMarkdownGenerator``.
  public init() {}

  /// Converts the given HTML string to Markdown.
  ///
  /// - Parameter htmlString: The HTML string to convert.
  /// - Returns: The generated Markdown string, trimmed of surrounding whitespace.
  /// - Throws: An error if the HTML cannot be parsed.
  public func markdown(fromHTML htmlString: String) throws -> String {
    let document = try SwiftSoup.parse(htmlString)
    guard let body = document.body() else {
      return ""
    }
    let blocks = try blockChildren(of: body)
    return Document(blocks)
      .format()
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

  // MARK: - SwiftSoup helpers

  /// The direct child elements of `element`, in document order.
  internal func childElements(of element: SwiftSoup.Element) -> [SwiftSoup.Element] {
    element.children().array()
  }

  /// The direct child elements of `element` with the given tag name.
  internal func childElements(
    of element: SwiftSoup.Element,
    named tag: String
  ) -> [SwiftSoup.Element] {
    element.children().array().filter { $0.tagName() == tag }
  }

  /// The value of `attribute` on `element`, or `nil` if absent or empty.
  internal func attribute(
    _ attribute: String,
    of element: SwiftSoup.Element
  ) throws -> String? {
    guard element.hasAttr(attribute) else {
      return nil
    }
    let value = try element.attr(attribute)
    return value.isEmpty ? nil : value
  }
}
