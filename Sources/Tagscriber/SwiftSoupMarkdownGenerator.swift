// swift-format-ignore-file
// swiftlint:disable all
import Markdown
import SwiftSoup

#warning("Should we move it to Contribute package?")
@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public struct SwiftSoupMarkdownGenerator: MarkdownGenerator {
  /// Returns the element's full text content, or `nil` when it is empty.
  ///
  /// Mirrors Kanna's `XMLElement.text`, which produced `nil` for elements
  /// without text. SwiftSoup's `text()` returns an empty string instead, so we
  /// normalise that back to `nil` to preserve the original `switch` semantics
  /// (the `.some(text)` cases must not match empty-text elements).
  private func text(of element: SwiftSoup.Element) throws -> String? {
    let text = try element.text()
    return text.isEmpty ? nil : text
  }

  /// The direct child elements of `element`, in document order.
  ///
  /// Mirrors Kanna's `element.xpath("/*")`.
  private func childElements(of element: SwiftSoup.Element) -> [SwiftSoup.Element] {
    element.children().array()
  }

  /// The direct child elements of `element` with the given tag name.
  ///
  /// Mirrors Kanna's `element.xpath("/\(tag)")`.
  private func childElements(
    of element: SwiftSoup.Element,
    named tag: String
  ) -> [SwiftSoup.Element] {
    element.children().array().filter { $0.tagName() == tag }
  }

  /// The value of `attribute` on `element`, or `nil` if absent/empty.
  ///
  /// Mirrors Kanna's `element.at_xpath("@attr")?.content`.
  private func attribute(
    _ attribute: String,
    of element: SwiftSoup.Element
  ) throws -> String? {
    guard element.hasAttr(attribute) else {
      return nil
    }
    let value = try element.attr(attribute)
    return value.isEmpty ? nil : value
  }

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  func markdown(from element: SwiftSoup.Element) throws -> [BlockMarkup] {
    let tagName = element.tagName()
    switch (tagName, try text(of: element)) {
    case let ("h4", .some(text)):
      return [Heading(level: 3, [Text(text)] as [InlineMarkup])]
    case ("hr", _):
      return [ThematicBreak()]
    case ("em", _):
      let children = try childElements(of: element).flatMap(inlineMarkup(from:))
      return [Paragraph([Emphasis(children)] as [InlineMarkup])]
    case ("img", _):
      let altText = try attribute("alt", of: element) ?? ""
      guard let src = try attribute("src", of: element) else {
        return []
      }
      let image = Image(source: src, [Text(altText)] as [RecurringInlineMarkup])
      return [Paragraph([image] as [InlineMarkup])]
    case ("script", _):
      return []
    case let ("h5", .some(text)):
      return [Heading(level: 5, [Text(text)] as [InlineMarkup])]
    case ("ul", _):
      return [UnorderedList(listItems(of: element))]
    case ("pre", _):
      return try childElements(of: element, named: "code").flatMap(markdown(from:))
    case ("figure", _):
      return []
    case let ("h2", .some(text)):
      return [Heading(level: 2, [Text(text)] as [InlineMarkup])]
    case ("ol", _):
      return [OrderedList(listItems(of: element))]
    case let ("a", .some(text)):
      guard let href = try attribute("href", of: element) else {
        return [Paragraph([Text(text)] as [InlineMarkup])]
      }
      let link = Link(destination: href, [Text(text)] as [RecurringInlineMarkup])
      return [Paragraph([link] as [InlineMarkup])]
    case ("dl", _):
      return [UnorderedList(listItems(of: element))]
    case let ("strong", .some(text)):
      return [Paragraph([Strong([Text(text)] as [InlineMarkup])] as [InlineMarkup])]
    case let ("code", .some(text)):
      return [CodeBlock(language: "swift", text)]
    case let ("div", .some(text)):
      return [Paragraph([Text(text)] as [InlineMarkup])]
    case ("ins", _):
      return []
    case let ("p", .some(text)):
      return [Paragraph([Text(text)] as [InlineMarkup])]
    case let ("h1", .some(text)):
      return [Heading(level: 1, [Text(text)] as [InlineMarkup])]
    case let ("blockquote", .some(text)):
      return [BlockQuote([Paragraph([Text(text)] as [InlineMarkup])] as [BlockMarkup])]
    case ("iframe", _):
      return []
    case let ("span", .some(text)):
      return [Paragraph([Text(text)] as [InlineMarkup])]
    case let ("h3", .some(text)):
      return [Heading(level: 3, [Text(text)] as [InlineMarkup])]
    case let ("li", .some(text)):
      return [Paragraph([Text(text)] as [InlineMarkup])]
    default:
      return []
    }
  }

  /// The list items produced from an element's direct `li` children.
  ///
  /// Mirrors Kanna's `element.xpath("/li").compactMap(markdown(from:))`.
  private func listItems(of element: SwiftSoup.Element) -> [ListItem] {
    childElements(of: element, named: "li").compactMap { child -> ListItem? in
      let blocks = (try? markdown(from: child)) ?? []
      guard !blocks.isEmpty else {
        return nil
      }
      return ListItem(blocks)
    }
  }

  /// Inline rendering used for nested children of inline containers (e.g. `em`).
  private func inlineMarkup(from element: SwiftSoup.Element) throws -> [InlineMarkup] {
    guard let text = try text(of: element) else {
      return []
    }
    return [Text(text)]
  }

  public func markdown(fromHTML htmlString: String) throws -> String {
    let document = try SwiftSoup.parse(htmlString)
    guard let body = document.body() else {
      return ""
    }
    let blocks = try childElements(of: body).flatMap(markdown(from:))
    let markdownDocument = Document(blocks)
    return markdownDocument.format()
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
