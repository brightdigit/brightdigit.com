//
//  SwiftSoupMarkdownGenerator+Markup.swift
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

// The block/inline switches dispatch on tag name and legitimately exceed the
// default cyclomatic-complexity limit; splitting them further would obscure the
// straightforward HTML→Markdown mapping.
// swiftlint:disable cyclomatic_complexity

extension SwiftSoupMarkdownGenerator {
  // MARK: - Block rendering

  /// Renders the block-level child elements of `element`, in document order.
  internal func blockChildren(of element: SwiftSoup.Element) throws -> [any BlockMarkup] {
    try childElements(of: element).flatMap(blockMarkup(for:))
  }

  /// Renders a single element as zero or more block-level nodes.
  internal func blockMarkup(for element: SwiftSoup.Element) throws -> [any BlockMarkup] {
    let tag = element.tagName()
    switch tag {
    case "h1", "h2", "h3", "h4", "h5", "h6":
      let level = Int(tag.dropFirst()) ?? 1
      let inline = try inlineChildren(of: element)
      return inline.isEmpty ? [] : [Heading(level: level, inline)]

    case "hr":
      return [ThematicBreak()]

    case "ul":
      return [UnorderedList(try listItems(of: element))]

    case "ol":
      return [OrderedList(try listItems(of: element))]

    case "pre":
      return [try codeBlock(from: element)]

    case "blockquote":
      let inner = try blockChildren(of: element)
      guard inner.isEmpty else {
        return [BlockQuote(inner)]
      }
      let inline = try inlineChildren(of: element)
      return inline.isEmpty ? [] : [BlockQuote([Paragraph(inline)])]

    case "p", "div", "section", "article":
      let inline = try inlineChildren(of: element)
      return inline.isEmpty ? [] : [Paragraph(inline)]

    case "img":
      let inline = try inlineMarkup(for: element)
      return inline.isEmpty ? [] : [Paragraph(inline)]

    case "dl":
      return try definitionList(from: element)

    case "table":
      return try tableBlocks(from: element)

    case "script", "style", "iframe", "figure", "ins", "noscript":
      // Intentionally dropped (non-content or unsupported, see Known limitations).
      return []

    case "a", "strong", "b", "em", "i", "code", "span":
      // Inline element appearing at block position: wrap in a paragraph.
      let inline = try inlineMarkup(for: element)
      return inline.isEmpty ? [] : [Paragraph(inline)]

    default:
      // Unknown container: descend so nested content is not silently lost.
      return try blockChildren(of: element)
    }
  }

  /// Builds a fenced code block from a `<pre>` element, inferring the language
  /// from the inner `<code class="language-…">` when present.
  private func codeBlock(from preElement: SwiftSoup.Element) throws -> CodeBlock {
    let codeElement = childElements(of: preElement, named: "code").first
    let language = try codeElement.flatMap(language(ofCode:))
    let source = try (codeElement ?? preElement).text()
    return CodeBlock(language: language, source)
  }

  /// Extracts a language identifier from a `<code>` element's class list,
  /// recognising the conventional `language-<id>` / `lang-<id>` tokens.
  private func language(ofCode element: SwiftSoup.Element) throws -> String? {
    let classNames = try element.className().split(separator: " ")
    for name in classNames {
      for prefix in ["language-", "lang-"] where name.hasPrefix(prefix) {
        let identifier = name.dropFirst(prefix.count)
        if !identifier.isEmpty {
          return String(identifier)
        }
      }
    }
    return nil
  }

  /// Produces list items from an element's direct `<li>` children, preserving
  /// inline formatting and nested lists.
  private func listItems(of element: SwiftSoup.Element) throws -> [ListItem] {
    try childElements(of: element, named: "li").compactMap { item -> ListItem? in
      let blocks = try listItemBlocks(of: item)
      return blocks.isEmpty ? nil : ListItem(blocks)
    }
  }

  /// Renders a `<li>`'s inline content as a leading paragraph followed by any
  /// nested block-level children (e.g. sub-lists).
  private func listItemBlocks(of item: SwiftSoup.Element) throws -> [any BlockMarkup] {
    var blocks: [any BlockMarkup] = []
    let inline = try inlineChildren(of: item)
    if !inline.isEmpty {
      blocks.append(Paragraph(inline))
    }
    for child in childElements(of: item)
    where Self.blockLevelTags.contains(child.tagName()) {
      blocks.append(contentsOf: try blockMarkup(for: child))
    }
    return blocks
  }

  // MARK: - Inline rendering

  /// Renders the inline content of `element`, walking child text and inline
  /// elements recursively while skipping block-level children.
  internal func inlineChildren(
    of element: SwiftSoup.Element
  ) throws -> [any InlineMarkup] {
    var result: [any InlineMarkup] = []
    for node in element.getChildNodes() {
      if let textNode = node as? SwiftSoup.TextNode {
        let text = textNode.text()
        if !text.isEmpty {
          result.append(Text(text))
        }
      } else if let child = node as? SwiftSoup.Element,
        !Self.blockLevelTags.contains(child.tagName())
      {
        result.append(contentsOf: try inlineMarkup(for: child))
      }
    }
    return result
  }

  /// Inline children coerced to ``RecurringInlineMarkup`` for containers
  /// (`<a>`, `<strong>`, `<em>`) whose children must recur. `Link`/`Image`
  /// are not recurring and cannot nest here, so they are dropped — a rare and
  /// acceptable loss that swift-markdown's type model does not allow anyway.
  private func recurringInlineChildren(
    of element: SwiftSoup.Element
  ) throws -> [any RecurringInlineMarkup] {
    try inlineChildren(of: element).compactMap { $0 as? any RecurringInlineMarkup }
  }

  /// Renders a single inline element (and its descendants).
  private func inlineMarkup(
    for element: SwiftSoup.Element
  ) throws -> [any InlineMarkup] {
    switch element.tagName() {
    case "a":
      let destination = try attribute("href", of: element)
      return [Link(destination: destination, try recurringInlineChildren(of: element))]

    case "strong", "b":
      return [Strong(try recurringInlineChildren(of: element))]

    case "em", "i":
      return [Emphasis(try recurringInlineChildren(of: element))]

    case "code":
      return [InlineCode(try element.text())]

    case "br":
      return [LineBreak()]

    case "img":
      guard let source = try attribute("src", of: element) else {
        return []
      }
      let alternate = try attribute("alt", of: element) ?? ""
      let altText: [any RecurringInlineMarkup] = [Text(alternate)]
      return [Image(source: source, altText)]

    default:
      // Unknown inline wrapper (span, etc.): flatten to its children.
      return try inlineChildren(of: element)
    }
  }
}

// swiftlint:enable cyclomatic_complexity
