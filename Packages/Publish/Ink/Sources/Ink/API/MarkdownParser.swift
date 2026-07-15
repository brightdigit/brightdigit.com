/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Markdown

///
/// A parser used to convert Markdown text into HTML.
///
/// You can use an instance of this type to either convert
/// a Markdown string into an HTML string, or into a `Markdown`
/// value, which also contains any metadata values found in
/// the parsed Markdown text.
///
/// To customize how this parser performs its work, attach
/// a `Modifier` using the `addModifier` method.
///
/// #40: this type is now a thin façade. Its public surface is unchanged, but parsing is
/// delegated to swift-markdown (aliased `CMarkdown`); the resulting AST is translated to
/// Ink's node IR by `MarkdownVisitor` and rendered by Ink's retained emitter, which
/// applies the registered modifiers via the unchanged `(html, rawString)` plumbing.
public struct MarkdownParser: Sendable {
  private var modifiers: ModifierCollection

  /// Initialize an instance, optionally passing an array
  /// of modifiers used to customize the parsing process.
  public init(modifiers: [Modifier] = []) {
    self.modifiers = ModifierCollection(modifiers: modifiers)
  }

  /// Add a modifier to this parser, which can be used to
  /// customize the parsing process. See `Modifier` for more info.
  public mutating func addModifier(_ modifier: Modifier) {
    modifiers.insert(modifier)
  }

  /// Convert a Markdown string into HTML, discarding any metadata
  /// found in the process. To preserve the Markdown's metadata,
  /// use the `parse` method instead.
  public func html(from markdown: String) -> String {
    parse(markdown).html
  }

  /// Parse a Markdown string into a `Markdown` value, which contains
  /// both the HTML representation of the given string, and also any
  /// metadata values found within it.
  public func parse(_ markdown: String) -> Markdown {
    // 1. Front-matter pre-pass (Ink-specific; not CommonMark).
    let lines = markdown.split(separator: "\n", omittingEmptySubsequences: false)
    var metadata: Metadata?
    let body: String

    if let parsed = Metadata.parse(lines: lines) {
      metadata = parsed.metadata.applyingModifiers(modifiers)
      body = lines[parsed.bodyLineIndex...].joined(separator: "\n")
    } else {
      body = markdown
    }

    // 2. Reference-link fallback table (swift-markdown resolves these natively, but
    //    we keep the collection as a fallback for unresolved destinations).
    let urls = NamedURLCollection(urlsByName: URLDeclaration.collectURLs(in: body))

    // 3. Parse the body with swift-markdown. Source ranges stay enabled (the visitor
    //    needs them to reconstruct each node's verbatim `rawString` for the modifier
    //    contract). `.disableSmartOpts` turns OFF cmark's SmartyPants pass — Ink never
    //    converted straight quotes/dashes/ellipses, so leaving smart on would rewrite
    //    `'"...--` into `'"…–` and diverge from Ink's output across nearly all content.
    let document = Document(parsing: body, options: [.disableSmartOpts])

    // 4. Translate the AST into Ink's node IR.
    let visitor = MarkdownVisitor(source: body, urls: urls)
    let fragments = visitor.makeFragments(from: document)

    // 5. Render the IR through Ink's retained emitter (applying modifiers).
    var titleHeading: Heading?
    let html = fragments.reduce(into: "") { result, wrapper in
      if titleHeading == nil,
        let heading = wrapper.fragment as? Heading,
        heading.level == 1
      {
        titleHeading = heading
      }

      let html = wrapper.fragment.html(
        usingURLs: urls,
        rawString: wrapper.rawString,
        applyingModifiers: modifiers
      )

      result.append(html)
    }

    return Markdown(
      html: html,
      titleHeading: titleHeading,
      metadata: metadata?.values ?? [:]
    )
  }
}
