/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Blockquote: Modifiable, HTMLConvertible, PlainTextConvertible {
    var modifierTarget: Modifier.Target { .blockquotes }

    /// Pre-rendered HTML of the blockquote's block-level children, produced by the
    /// swift-markdown visitor (#40). Ink's `Reader` used to build a `FormattedText`
    /// here; the body now arrives already rendered (CommonMark-correct: the contained
    /// paragraphs already carry their own `<p>` wrappers).
    private var renderedBody: String

    init(renderedBody: String) {
        self.renderedBody = renderedBody
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        "<blockquote>\(renderedBody)</blockquote>"
    }

    func plainText() -> String {
        renderedBody
    }
}
