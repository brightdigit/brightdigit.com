/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct HorizontalLine: Modifiable, HTMLConvertible, PlainTextConvertible {
    var modifierTarget: Modifier.Target { .horizontalLines }

    init() {}

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        "<hr>"
    }

    func plainText() -> String {
        // Since we want to strip all HTML from plain text output,
        // there is nothing to return here, just an empty string.
        ""
    }
}
