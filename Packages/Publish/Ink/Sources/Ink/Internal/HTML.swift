/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct HTML: Modifiable, HTMLConvertible {
  internal var modifierTarget: Modifier.Target { .html }

  private var string: String

  internal init(string: String) {
    self.string = string
  }

  internal func html(
    usingURLs urls: NamedURLCollection,
    modifiers: ModifierCollection
  ) -> String {
    string
  }
}
