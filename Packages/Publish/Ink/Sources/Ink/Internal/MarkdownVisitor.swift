/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*
*  #40: swift-markdown front end. This visitor walks swift-markdown's `Document`
*  AST and constructs Ink's retained node IR (`Blockquote`, `CodeBlock`, `Heading`,
*  …). The IR is then rendered to HTML by Ink's existing emitter, which applies the
*  registered modifiers via the unchanged `(html, rawString)` plumbing. swift-markdown
*  replaces only Ink's hand-written `Reader`; emission and the modifier contract are reused.
*/

import Markdown

/// Walks a swift-markdown AST and produces Ink's block-level node IR.
///
/// Inline content is rendered to HTML eagerly (see `InlineHTMLRenderer`) so that the
/// retained Ink node emitters need only wrap it. The original source string is captured
/// so each node's verbatim `rawString` can be reconstructed from its `SourceRange`
/// (the substring the Ink modifier closures expect).
internal struct MarkdownVisitor {
    /// The full markdown source (body only — front matter already stripped). Used to
    /// reconstruct each block's verbatim `rawString` from its swift-markdown `SourceRange`.
    private let source: String
    /// Reference-link declarations parsed by Ink's retained pre-pass, used to resolve
    /// `[text][name]` / `[name]` style links that swift-markdown leaves unresolved.
    private let urls: NamedURLCollection

    init(source: String, urls: NamedURLCollection) {
        self.source = source
        self.urls = urls
    }

    /// Convert a top-level document into the ordered list of Ink block nodes, each
    /// paired with its verbatim source slice (the modifier `rawString`).
    func makeFragments(from document: Document) -> [ParsedFragment] {
        document.blockChildren.compactMap { block in
            guard let fragment = fragment(for: block) else { return nil }
            return ParsedFragment(fragment: fragment, rawString: rawString(for: block))
        }
    }

    /// A block node paired with its verbatim source slice (the modifier `rawString`).
    struct ParsedFragment {
        var fragment: Fragment
        var rawString: Substring
    }
}

private extension MarkdownVisitor {
    /// Reconstruct the verbatim source substring for a block from its `SourceRange`,
    /// reproducing the slice Ink's old `Reader` recorded (e.g. `> youtube …` for a
    /// blockquote, the full fenced block for a code block).
    func rawString(for markup: Markup) -> Substring {
        guard let range = markup.range else { return "" }
        let lower = source.lineColumnIndex(line: range.lowerBound.line,
                                           column: range.lowerBound.column)
        let upper = source.lineColumnIndex(line: range.upperBound.line,
                                           column: range.upperBound.column)
        guard let lower, let upper, lower <= upper else { return "" }
        return source[lower..<upper]
    }

    func fragment(for markup: Markup) -> Fragment? {
        switch markup {
        case let blockQuote as BlockQuote:
            return Blockquote(renderedBody: renderBlocks(blockQuote.blockChildren))
        case let codeBlock as Markdown::CodeBlock:
            return makeCodeBlock(codeBlock)
        case let heading as Markdown::Heading:
            return Heading(level: heading.level,
                           renderedBody: renderInline(heading.inlineChildren),
                           plainText: heading.plainText)
        case let paragraph as Markdown::Paragraph:
            return Paragraph(renderedBody: renderInline(paragraph.inlineChildren),
                             plainText: paragraph.plainText)
        case is ThematicBreak:
            return HorizontalLine()
        case let htmlBlock as HTMLBlock:
            // swift-markdown's `rawHTML` retains the block's trailing newline(s); Ink's
            // `Reader` stopped at the closing `>`, so it never emitted a trailing newline
            // after an HTML block. Strip the trailing newline(s) to match Ink — otherwise
            // every HTML block injects a stray `\n` (at EOF, or between the block and the
            // following block).
            return HTML(string: trimTrailingNewlines(htmlBlock.rawHTML))
        case let list as UnorderedList:
            return makeList(items: Array(list.listItems), kind: .unordered)
        case let list as Markdown::OrderedList:
            return makeList(items: Array(list.listItems),
                            kind: .ordered(firstNumber: Int(list.startIndex)))
        case let table as Markdown::Table:
            return makeTable(table)
        default:
            // Unsupported block (e.g. block directives, Doxygen) — render as plain HTML.
            return HTML(string: format(markup))
        }
    }

    /// Render a sequence of block-level nodes into a single HTML string (used inside
    /// blockquotes and list items, where Ink's emitter expects pre-rendered bodies).
    func renderBlocks<S: Sequence>(_ blocks: S) -> String where S.Element == BlockMarkup {
        blocks.reduce(into: "") { html, block in
            guard let fragment = fragment(for: block) else { return }
            html.append(fragment.html(usingURLs: urls, modifiers: ModifierCollection(modifiers: [])))
        }
    }

    func renderInline<S: Sequence>(_ inlines: S) -> String where S.Element == InlineMarkup {
        var renderer = InlineHTMLRenderer(urls: urls)
        return inlines.reduce(into: "") { html, inline in
            html.append(renderer.render(inline))
        }
    }

    func makeCodeBlock(_ codeBlock: Markdown::CodeBlock) -> CodeBlock {
        // swift-markdown includes a trailing newline in `code`; Ink stored the code
        // exactly as consumed (also with a trailing newline for fenced blocks).
        let language = (codeBlock.language ?? "").trimmingCharacters(in: .whitespaces)
        return CodeBlock(language: Substring(language),
                         code: HTMLEscaping.escape(codeBlock.code))
    }

    func makeList(items: [ListItem], kind: List.Kind) -> List {
        let mapped = items.map { item -> List.Item in
            // A list item's first paragraph is rendered "tight" (no <p>) by Ink; the
            // remaining blocks (nested lists, extra paragraphs) follow as block HTML.
            var text = ""
            var trailing = ""
            for (index, block) in item.blockChildren.enumerated() {
                if index == 0, let paragraph = block as? Markdown::Paragraph {
                    text = renderInline(paragraph.inlineChildren)
                } else if let fragment = fragment(for: block) {
                    trailing.append(fragment.html(usingURLs: urls,
                                                  modifiers: ModifierCollection(modifiers: [])))
                }
            }
            return List.Item(renderedText: text + trailing)
        }
        return List(kind: kind, renderedItems: mapped)
    }

    func makeTable(_ table: Markdown::Table) -> Table {
        let alignments = table.columnAlignments.map { alignment -> Table.ColumnAlignment in
            switch alignment {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            case nil: return .none
            }
        }
        let header = table.head.cells.map { renderInline($0.inlineChildren) }
        let bodyRows = table.body.rows.map { row in
            Array(row.cells.map { renderInline($0.inlineChildren) })
        }
        return Table(renderedHeader: Array(header),
                     renderedRows: Array(bodyRows),
                     columnAlignments: alignments)
    }

    func format(_ markup: Markup) -> String {
        // Fall back to the verbatim source slice for unsupported block types.
        String(rawString(for: markup))
    }

    /// Strip trailing newline characters, reproducing Ink's HTML-block behaviour (its
    /// `Reader` stopped at the closing `>`, never consuming the trailing newline).
    func trimTrailingNewlines(_ string: String) -> String {
        var result = Substring(string)
        while result.last == "\n" || result.last == "\r" {
            result = result.dropLast()
        }
        return String(result)
    }
}
