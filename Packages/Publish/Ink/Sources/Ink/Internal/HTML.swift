/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct HTML: Modifiable, HTMLConvertible, PlainTextConvertible {
    var modifierTarget: Modifier.Target { .html }

    private var string: String

    init(string: String) {
        self.string = string
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        string
    }

    func plainText() -> String {
        // Since we want to strip all HTML from plain text output,
        // there is nothing to return here, just an empty string.
        ""
    }
}
