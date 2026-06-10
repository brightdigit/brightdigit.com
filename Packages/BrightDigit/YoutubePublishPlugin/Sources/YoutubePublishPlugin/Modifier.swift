//
//  Modifier.swift
//  YoutubePublishPlugin
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import Ink
import Publish

/// A modifier for Ink that helps rendering YouTube blockquotes into an HTML string.
extension Modifier {
  /// Creates a new modifier.
  /// It uses a renderer to convert a YouTube blockquote into HTML.
  ///
  /// - Parameter renderer: The renderer to use for rendering YouTube blockquotes.
  /// - Returns: A new modifier.
  public static func youtubeBlockQuote(using renderer: YoutubeRenderer) -> Self {
    Modifier(target: .blockquotes) { html, markdown in
      let prefix = "youtube "
      var markdown = markdown.dropFirst().trimmingCharacters(in: .whitespaces)
      guard markdown.hasPrefix(prefix) else {
        return html
      }

      markdown = markdown.dropFirst(prefix.count).trimmingCharacters(in: .newlines)

      guard let url = URL(string: markdown) else {
        fatalError("Invalid youtube URL \(markdown)")
      }

      let generator = YoutubeEmbedGenerator(url: url, configuration: .default)
      do {
        let youtube = try generator.generate().get()
        return try renderer.render(youtube: youtube)
      } catch {
        fatalError("Failed to render youtube embed: \(error)")
      }
    }
  }
}
