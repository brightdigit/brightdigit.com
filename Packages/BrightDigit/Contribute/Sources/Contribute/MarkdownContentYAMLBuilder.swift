//
//  MarkdownContentYAMLBuilder.swift
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

/// A `MarkdownContentBuilder` that combines YAML front matter with markdown content.
public struct MarkdownContentYAMLBuilder<
  SourceType,
  ExtractorType: MarkdownExtractor,
  ExporterType: FrontMatterExporter
>: MarkdownContentBuilder
where
  ExporterType.SourceType == SourceType,
  ExtractorType.SourceType == SourceType
{
  private let contentFormatter: FrontMatterMarkdownFormatter = .simple

  private let frontMatterExporter: ExporterType
  private let markdownExtractor: ExtractorType

  /// Initializes the builder with the given exporter and extractor.
  ///
  /// - Parameters:
  ///   - frontMatterExporter: The exporter that produces front matter text
  ///     from the source data.
  ///   - markdownExtractor: The extractor that produces markdown text from
  ///     the source data.
  public init(
    frontMatterExporter: ExporterType,
    markdownExtractor: ExtractorType
  ) {
    self.frontMatterExporter = frontMatterExporter
    self.markdownExtractor = markdownExtractor
  }

  /// Builds the content by joining the front matter and markdown text.
  ///
  /// - Parameters:
  ///   - source: The source data from which to generate the content.
  ///   - htmlToMarkdown: A function that converts HTML to markdown.
  /// - Returns: The front matter and markdown formatted as a single string.
  /// - Throws: An error if the front matter export or markdown extraction fails.
  public func content(
    from source: SourceType,
    using htmlToMarkdown: @escaping (String) throws -> String
  ) throws -> String {
    let frontMatterText = try frontMatterExporter.frontMatterText(from: source)
    let markdownText = try markdownExtractor.markdown(from: source, using: htmlToMarkdown)
    return contentFormatter.format(
      frontMatterText: frontMatterText,
      withMarkdown: markdownText
    )
  }
}
