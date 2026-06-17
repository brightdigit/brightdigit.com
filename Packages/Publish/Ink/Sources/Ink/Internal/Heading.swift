/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Heading: Modifiable, HTMLConvertible, PlainTextConvertible {
    var modifierTarget: Modifier.Target { .headings }
    var level: Int

    /// Pre-rendered inline HTML of the heading text (#40).
    private var renderedBody: String
    /// Plain-text form, used for document-title inference.
    private var plainTextValue: String

    init(level: Int, renderedBody: String, plainText: String) {
        self.level = level
        self.renderedBody = renderedBody
        self.plainTextValue = plainText
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let tagName = "h\(level)"
        return "<\(tagName)>\(renderedBody)</\(tagName)>"
    }

    func plainText() -> String {
        plainTextValue
    }
}
