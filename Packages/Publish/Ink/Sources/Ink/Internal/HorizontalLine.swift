/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct HorizontalLine: Modifiable, HTMLConvertible {
  internal var modifierTarget: Modifier.Target { .horizontalLines }

  internal init() {}

  internal func html(
    usingURLs urls: NamedURLCollection,
    modifiers: ModifierCollection
  ) -> String {
    "<hr>"
  }
}
