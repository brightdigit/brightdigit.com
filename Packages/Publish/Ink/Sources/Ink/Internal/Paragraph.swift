/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Paragraph: Modifiable, HTMLConvertible, PlainTextConvertible {
  internal var modifierTarget: Modifier.Target { .paragraphs }

  /// Pre-rendered inline HTML of the paragraph (#40).
  private var renderedBody: String
  private var plainTextValue: String

  internal init(renderedBody: String, plainText: String) {
    self.renderedBody = renderedBody
    self.plainTextValue = plainText
  }

  internal func html(
    usingURLs urls: NamedURLCollection,
    modifiers: ModifierCollection
  ) -> String {
    "<p>\(renderedBody)</p>"
  }

  internal func plainText() -> String {
    plainTextValue
  }
}
