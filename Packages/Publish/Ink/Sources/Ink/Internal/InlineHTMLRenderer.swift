/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*
*  #40: renders swift-markdown inline nodes to the same HTML Ink's `FormattedText`
*  emitter produced (`<em>`, `<strong>`, `<s>`, `<code>`, `<a>`, `<img>`, `<br>`),
*  using Ink's `<`/`>`/`&`-only escaping. Reference-style links/images are resolved
*  against the retained `NamedURLCollection` pre-pass.
*/

import Markdown

/// Converts swift-markdown inline markup into Ink-compatible HTML.
internal struct InlineHTMLRenderer {
    private let urls: NamedURLCollection

    init(urls: NamedURLCollection) {
        self.urls = urls
    }

    mutating func render(_ inline: InlineMarkup) -> String {
        switch inline {
        case let text as Text:
            return HTMLEscaping.escape(text.string)
        case let emphasis as Emphasis:
            return wrap("em", emphasis.inlineChildren)
        case let strong as Strong:
            return wrap("strong", strong.inlineChildren)
        case let strikethrough as Strikethrough:
            return wrap("s", strikethrough.inlineChildren)
        case let code as Markdown::InlineCode:
            return "<code>\(HTMLEscaping.escape(code.code))</code>"
        case let link as Markdown::Link:
            return renderLink(link)
        case let image as Markdown::Image:
            return renderImage(image)
        case is LineBreak:
            return "<br>"
        case is SoftBreak:
            // Ink joins soft-wrapped lines with a single space.
            return " "
        case let html as InlineHTML:
            return html.rawHTML
        default:
            return HTMLEscaping.escape(inline.plainText)
        }
    }

    private mutating func renderChildren<S: Sequence>(_ inlines: S) -> String
    where S.Element == InlineMarkup {
        inlines.reduce(into: "") { $0.append(render($1)) }
    }

    private mutating func wrap<S: Sequence>(_ tag: String, _ inlines: S) -> String
    where S.Element == InlineMarkup {
        "<\(tag)>\(renderChildren(inlines))</\(tag)>"
    }

    private mutating func renderLink(_ link: Markdown::Link) -> String {
        let destination = resolve(destination: link.destination, fallbackText: link.plainText)
        let title = renderChildren(link.inlineChildren)
        return "<a href=\"\(destination)\">\(title)</a>"
    }

    private mutating func renderImage(_ image: Markdown::Image) -> String {
        let source = resolve(destination: image.source, fallbackText: image.plainText)
        var alt = renderChildren(image.inlineChildren)
        if !alt.isEmpty {
            alt = " alt=\"\(alt)\""
        }
        return "<img src=\"\(source)\"\(alt)/>"
    }

    /// Resolve a link/image destination: swift-markdown leaves the destination `nil`
    /// for unresolved reference-style links, so fall back to the retained Ink reference
    /// table keyed on the link text (mirroring Ink's `Link.Target.reference`).
    private func resolve(destination: String?, fallbackText: String) -> String {
        if let destination, !destination.isEmpty {
            return destination
        }
        if let referenced = urls.url(named: Substring(fallbackText)) {
            return String(referenced)
        }
        return fallbackText
    }
}
