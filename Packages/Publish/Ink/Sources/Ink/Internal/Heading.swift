/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Heading: Modifiable, HTMLConvertible, PlainTextConvertible {
  internal var modifierTarget: Modifier.Target { .headings }
  internal var level: Int

  /// Pre-rendered inline HTML of the heading text (#40).
  private var renderedBody: String
  /// Plain-text form, used for document-title inference.
  private var plainTextValue: String

  internal init(level: Int, renderedBody: String, plainText: String) {
    self.level = level
    self.renderedBody = renderedBody
    self.plainTextValue = plainText
  }

  internal func html(
    usingURLs urls: NamedURLCollection,
    modifiers: ModifierCollection
  ) -> String {
    let tagName = "h\(level)"
    return "<\(tagName)>\(renderedBody)</\(tagName)>"
  }

  internal func plainText() -> String {
    plainTextValue
  }
}
