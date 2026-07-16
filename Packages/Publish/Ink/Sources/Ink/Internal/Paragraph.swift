/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Paragraph: Modifiable, HTMLConvertible {
  internal var modifierTarget: Modifier.Target { .paragraphs }

  /// Pre-rendered inline HTML of the paragraph (#40).
  private var renderedBody: String

  internal init(renderedBody: String) {
    self.renderedBody = renderedBody
  }

  internal func html(
    usingURLs urls: NamedURLCollection,
    modifiers: ModifierCollection
  ) -> String {
    "<p>\(renderedBody)</p>"
  }
}
