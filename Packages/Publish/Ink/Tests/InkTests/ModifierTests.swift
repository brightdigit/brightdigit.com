/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class ModifierTests: XCTestCase {
    func testModifierInput() {
        var allHTML = [String]()
        var allMarkdown = [Substring]()

        let parser = MarkdownParser(modifiers: [
            Modifier(target: .paragraphs) { html, markdown in
                allHTML.append(html)
                allMarkdown.append(markdown)
                return html
            }
        ])

        let html = parser.html(from: "One\n\nTwo\n\nThree")
        XCTAssertEqual(html, "<p>One</p><p>Two</p><p>Three</p>")
        XCTAssertEqual(allHTML, ["<p>One</p>", "<p>Two</p>", "<p>Three</p>"])
        XCTAssertEqual(allMarkdown, ["One", "Two", "Three"])
    }

    // #40 KNOWN LIMITATION: the swift-markdown front end renders inline markup (links,
    // inline code, emphasis, images) eagerly while translating the AST, so *inline*-level
    // modifier targets (`.links`, `.inlineCode`, `.images`) are NOT dispatched. Only the
    // *block*-level targets are — which is everything the live site uses (`.codeBlocks`,
    // `.blockquotes`, `.headings`, `.paragraphs`). These tests pin the supported behaviour:
    // the inline `.links`/`.inlineCode` modifiers are inert, so the link/code render as-is.
    func testInitializingParserWithModifiers() {
        let parser = MarkdownParser(modifiers: [
            Modifier(target: .links) { "LINK:" + $0.html },
            Modifier(target: .inlineCode) { _ in "<em>Replacement</em>" }
        ])

        let html = parser.html(from: "Text [Link](url) `code`")

        XCTAssertEqual(
            html,
            #"<p>Text <a href="url">Link</a> <code>code</code></p>"#
        )
    }

    func testAddingModifiers() {
        var parser = MarkdownParser()
        // `.headings` is a block-level target and IS dispatched; the inline ones are inert.
        parser.addModifier(Modifier(target: .headings) { _ in "<h1>New heading</h1>" })
        parser.addModifier(Modifier(target: .links) { "LINK:" + $0.html })
        parser.addModifier(Modifier(target: .inlineCode) { _ in "Code" })

        let html = parser.html(from: """
        # Heading

        Text [Link](url) `code`
        """)

        XCTAssertEqual(html, #"""
        <h1>New heading</h1><p>Text <a href="url">Link</a> <code>code</code></p>
        """#)
    }

    func testMultipleModifiersForSameTarget() {
        var parser = MarkdownParser()

        parser.addModifier(Modifier(target: .codeBlocks) {
            " is cool:</p>" + $0.html
        })

        parser.addModifier(Modifier(target: .codeBlocks) {
            "<p>Code" + $0.html
        })

        let html = parser.html(from: """
        ```
        Code
        ```
        """)

        XCTAssertEqual(html, "<p>Code is cool:</p><pre><code>Code\n</code></pre>")
    }
}

extension ModifierTests {
    static var allTests: Linux.TestList<ModifierTests> {
        return [
            ("testModifierInput", testModifierInput),
            ("testInitializingParserWithModifiers", testInitializingParserWithModifiers),
            ("testAddingModifiers", testAddingModifiers),
            ("testMultipleModifiersForSameTarget", testMultipleModifiersForSameTarget)
        ]
    }
}
