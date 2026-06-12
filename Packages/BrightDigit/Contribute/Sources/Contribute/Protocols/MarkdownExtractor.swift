//
//  MarkdownExtractor.swift
//  Contribute
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

/// A protocol that extracts markdown from a source data.
public protocol MarkdownExtractor {
  /// The type of the source data.
  associatedtype SourceType

  /// Initialize a new instance of `MarkdownExtractor`.
  init()

  /// Extracts the markdown from the given source data, using
  /// the given `htmlToMarkdown` function to convert HTML to Markdown.
  ///
  /// - Parameters:
  ///   - source: The source data.
  ///   - htmlToMarkdown: A function that converts HTML to Markdown.
  /// - Returns: The markdown text.
  /// - Throws: An error if the markdown couldn't be extracted from the source.
  func markdown(
    from source: SourceType,
    using htmlToMarkdown: @escaping (String) throws -> String
  ) throws -> String
}
