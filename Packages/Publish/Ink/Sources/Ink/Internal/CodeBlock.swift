/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct CodeBlock: Modifiable, HTMLConvertible, PlainTextConvertible {
    var modifierTarget: Modifier.Target { .codeBlocks }

    private var language: Substring
    /// The code content, already HTML-escaped (`<`, `>`, `&`) by the visitor (#40).
    private var code: String

    init(language: Substring, code: String) {
        self.language = language
        self.code = code
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let languageClass = language.isEmpty ? "" : " class=\"language-\(language)\""
        return "<pre><code\(languageClass)>\(code)</code></pre>"
    }

    func plainText() -> String {
        code
    }
}
