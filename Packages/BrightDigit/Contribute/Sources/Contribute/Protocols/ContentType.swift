//
//  ContentType.swift
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

/// A protocol that represents a content type.
public protocol ContentType {
  /// The type of the source data.
  associatedtype SourceType

  /// The type of the markdown extractor.
  associatedtype MarkdownExtractorType: MarkdownExtractor
  where MarkdownExtractorType.SourceType == SourceType

  /// The type of the front matter translator.
  associatedtype FrontMatterTranslatorType: FrontMatterTranslator
  where FrontMatterTranslatorType.SourceType == SourceType
}

extension ContentType {
  /// Returns a YAML content builder for this content type.
  ///
  /// - Returns: An instance of `MarkdownContentYAMLBuilder`.
  public static func contentBuilder() -> MarkdownContentYAMLBuilder<
    SourceType,
    MarkdownExtractorType,
    FrontMatterYAMLExporter<SourceType, FrontMatterTranslatorType>
  > {
    MarkdownContentYAMLBuilder(
      frontMatterExporter: .init(translator: Self.FrontMatterTranslatorType()),
      markdownExtractor: MarkdownExtractorType()
    )
  }

  /// Writes the given sources at the given content path URL.
  ///
  /// - Parameters:
  ///   - sources: List of source data to write.
  ///   - contentPathURL: The content path URL.
  ///   - destinationURLGenerator: A function that generates content URLs from
  ///     the given sources.
  ///   - htmlToMarkdown: A function that converts HTML to markdown.
  ///   - options: The options for the markdown content builder.
  /// - Throws: An error if the sources could not be written.
  ///
  /// - Note: The `destinationURLGenerator` function must be able to generate
  ///   destination URLs for all of the sources in the `sources` array.
  public static func write<URLGeneratorType: ContentURLGenerator>(
    from sources: [SourceType],
    atContentPathURL contentPathURL: URL,
    basedOn destinationURLGenerator: URLGeneratorType,
    using htmlToMarkdown: @escaping (String) throws -> String,
    options: MarkdownContentBuilderOptions = []
  ) throws where URLGeneratorType.SourceType == Self.SourceType {
    try contentBuilder()
      .write(
        from: sources,
        atContentPathURL: contentPathURL,
        basedOn: destinationURLGenerator,
        using: htmlToMarkdown,
        options: options
      )
  }

  /// Writes the given sources at the given content path URL, using the given
  /// fileNameWithoutExtension function to generate the file name without extension.
  ///
  /// - Parameters:
  ///   - sources: List of source data to write.
  ///   - contentPathURL: The content path URL.
  ///   - fileNameWithoutExtension: A function that generates the file name
  ///   without extension for the given source data.
  ///   - htmlToMarkdown: A function that converts HTML to Markdown.
  ///   - options: The options for the Markdown content builder.
  /// - Throws: An error if the sources could not be written.
  public static func write(
    from sources: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String,
    using htmlToMarkdown: @escaping (String) throws -> String,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    let contentURLGenerator = FileNameGenerator(fileNameWithoutExtension)
    try write(
      from: sources,
      atContentPathURL: contentPathURL,
      basedOn: contentURLGenerator,
      using: htmlToMarkdown,
      options: options
    )
  }
}
