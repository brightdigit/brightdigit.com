/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct HorizontalLine: Modifiable, HTMLConvertible, PlainTextConvertible {
  internal var modifierTarget: Modifier.Target { .horizontalLines }

  internal init() {}

  internal func html(
    usingURLs urls: NamedURLCollection,
    modifiers: ModifierCollection
  ) -> String {
    "<hr>"
  }

  internal func plainText() -> String {
    // Since we want to strip all HTML from plain text output,
    // there is nothing to return here, just an empty string.
    ""
  }
}
