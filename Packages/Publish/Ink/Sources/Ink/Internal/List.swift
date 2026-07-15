/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct List: Modifiable, HTMLConvertible, PlainTextConvertible {
  internal var modifierTarget: Modifier.Target { .lists }

  private var kind: Kind
  private var items: [Item]

  internal init(kind: Kind, renderedItems: [Item]) {
    self.kind = kind
    self.items = renderedItems
  }

  internal func html(
    usingURLs urls: NamedURLCollection,
    modifiers: ModifierCollection
  ) -> String {
    let tagName: String
    let startAttribute: String

    switch kind {
    case .unordered:
      tagName = "ul"
      startAttribute = ""
    case .ordered(let startingIndex):
      tagName = "ol"

      if startingIndex != 1 {
        startAttribute = #" start="\#(startingIndex)""#
      } else {
        startAttribute = ""
      }
    }

    let body = items.reduce(into: "") { html, item in
      html.append(item.html(usingURLs: urls, modifiers: modifiers))
    }

    return "<\(tagName)\(startAttribute)>\(body)</\(tagName)>"
  }

  internal func plainText() -> String {
    var isFirst = true

    return items.reduce(into: "") { string, item in
      if isFirst {
        isFirst = false
      } else {
        string.append(", ")
      }

      string.append(item.plainText())
    }
  }
}

extension List {
  /// A single list item, holding its pre-rendered inner HTML (#40). The item's first
  /// paragraph is rendered "tight" (no `<p>`) and any nested lists/blocks follow.
  internal struct Item: HTMLConvertible {
    internal var renderedText: String

    internal func html(
      usingURLs urls: NamedURLCollection,
      modifiers: ModifierCollection
    ) -> String {
      "<li>\(renderedText)</li>"
    }

    internal func plainText() -> String {
      renderedText
    }
  }

  internal enum Kind {
    case unordered
    case ordered(firstNumber: Int)
  }
}
