/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct CodeBlock: Modifiable, HTMLConvertible, PlainTextConvertible {
  internal var modifierTarget: Modifier.Target { .codeBlocks }

  private var language: Substring
  /// The code content, already HTML-escaped (`<`, `>`, `&`) by the visitor (#40).
  private var code: String

  internal init(language: Substring, code: String) {
    self.language = language
    self.code = code
  }

  internal func html(
    usingURLs urls: NamedURLCollection,
    modifiers: ModifierCollection
  ) -> String {
    let languageClass = language.isEmpty ? "" : " class=\"language-\(language)\""
    return "<pre><code\(languageClass)>\(code)</code></pre>"
  }

  internal func plainText() -> String {
    code
  }
}
