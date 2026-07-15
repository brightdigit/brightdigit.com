/**
*  Splash-plugin for Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Publish
import Splash
import Ink

public extension Plugin {
    static func splash(withClassPrefix classPrefix: String) -> Self {
        Plugin(name: "Splash") { context in
            context.markdownParser.addModifier(
                .splashCodeBlocks(withFormat: HTMLOutputFormat(
                    classPrefix: classPrefix
                ))
            )
        }
    }
}

public extension Modifier {
    static func splashCodeBlocks(withFormat format: HTMLOutputFormat = .init()) -> Self {
        // The Ink modifier closure is `@Sendable`; `SyntaxHighlighter` isn't
        // Sendable, so it is created inside the closure (capturing the Sendable
        // `format`) rather than hoisted and captured.
        return Modifier(target: .codeBlocks) { html, markdown in
            var markdown = markdown.dropFirst("```".count)

            guard !markdown.hasPrefix("no-highlight") else {
                return html
            }

            markdown = markdown
                .drop(while: { !$0.isNewline })
                .dropFirst()
                .dropLast("\n```".count)

            let highlighter = SyntaxHighlighter(format: format)
            let highlighted = highlighter.highlight(String(markdown))
            return "<pre><code>" + highlighted + "\n</code></pre>"
        }
    }
}

