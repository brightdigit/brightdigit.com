//
//  SimpleFrontMatterMarkdownFormatter.swift
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

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A simple formatter implementation for front matter and markdown together.
///
/// ```md
/// ---
/// title: WWDC 2018 - What Does It Mean For Businesses?
/// date: 2018-08-14 00:00
/// ---
/// <p>In this episode, we talk about <strong>WWDC 2018</strong></p>
/// ```
public struct SimpleFrontMatterMarkdownFormatter: FrontMatterMarkdownFormatter {
  /// Formats the given front matter text and markdown text into a single string.
  ///
  /// - Parameters:
  ///   - frontMatterText: The front matter text.
  ///   - markdownText: The markdown text.
  /// - Returns: The formatted string.
  public func format(
    frontMatterText: String,
    withMarkdown markdownText: String
  ) -> String {
    ["---", frontMatterText, "---", markdownText].joined(separator: "\n")
  }
}

extension FrontMatterMarkdownFormatter where Self == SimpleFrontMatterMarkdownFormatter {
  /// A static property that returns a `SimpleFrontMatterMarkdownFormatter` instance.
  public static var simple: SimpleFrontMatterMarkdownFormatter { .init() }
}
