/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Paragraph: Modifiable, HTMLConvertible, PlainTextConvertible {
    var modifierTarget: Modifier.Target { .paragraphs }

    /// Pre-rendered inline HTML of the paragraph (#40).
    private var renderedBody: String
    private var plainTextValue: String

    init(renderedBody: String, plainText: String) {
        self.renderedBody = renderedBody
        self.plainTextValue = plainText
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        "<p>\(renderedBody)</p>"
    }

    func plainText() -> String {
        plainTextValue
    }
}
