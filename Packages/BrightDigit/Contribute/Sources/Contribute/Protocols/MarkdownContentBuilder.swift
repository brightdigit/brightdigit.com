//
//  MarkdownContentBuilder.swift
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

/// A protocol that builds markdown content.
public protocol MarkdownContentBuilder {
  /// The type of the source data.
  associatedtype SourceType

  /// Builds markdown content from the given input source, using the provided
  /// `htmlToMarkdown` function.
  ///
  /// - Parameters:
  ///   - source: The source data from which to generate markdown content.
  ///   - htmlToMarkdown: A function that converts HTML to Markdown.
  /// - Returns: The generated markdown content.
  /// - Throws: An error if the source data could not be processed.
  func content(
    from source: SourceType,
    using htmlToMarkdown: @escaping (String) throws -> String
  ) throws -> String
}

extension MarkdownContentBuilder {
  /// Generates the markdown content from the given source data, then writes it
  /// at the given content path URL.
  ///
  /// - Parameters:
  ///   - source: The source data.
  ///   - contentPathURL: The content path URL.
  ///   - destinationURLGenerator: A function that generates the destination URL for
  ///     the source data.
  ///   - htmlToMarkdown: A function that converts HTML to markdown.
  ///   - shouldOverwrite: Whether to overwrite the destination file if it already exists.
  /// - Returns: Whether the file already existed.
  /// - Throws: An error if the content could not be generated or written.
  public func write<URLGeneratorType: ContentURLGenerator>(
    from source: SourceType,
    atContentPathURL contentPathURL: URL,
    basedOn destinationURLGenerator: URLGeneratorType,
    using htmlToMarkdown: @escaping (String) throws -> String,
    shouldOverwrite: Bool = false
  ) throws -> Bool where URLGeneratorType.SourceType == Self.SourceType {
    let destinationURL = destinationURLGenerator.destinationURL(
      from: source,
      atContentPathURL: contentPathURL
    )

    let fileExists = FileManager.default.fileExists(atPath: destinationURL.path)

    guard !fileExists || shouldOverwrite else {
      return fileExists
    }

    let contentText = try content(from: source, using: htmlToMarkdown)
    try contentText.write(to: destinationURL, atomically: true, encoding: .utf8)
    return fileExists
  }

  /// Generates the markdown content from each of the give source data, then writes it
  /// at the given content path URL.
  ///
  /// - Parameters:
  ///   - sources: List of source data to write.
  ///   - contentPathURL: The content path URL.
  ///   - destinationURLGenerator: A function that generates the destination URL for
  ///     the source data.
  ///   - htmlToMarkdown: A function that converts HTML to Markdown.
  ///   - options: A set of options that control the behavior of the write operation.
  /// - Throws: An error if the write operation fails.
  public func write<URLGeneratorType: ContentURLGenerator>(
    from sources: [SourceType],
    atContentPathURL contentPathURL: URL,
    basedOn destinationURLGenerator: URLGeneratorType,
    using htmlToMarkdown: @escaping (String) throws -> String,
    options: MarkdownContentBuilderOptions = []
  ) throws where URLGeneratorType.SourceType == SourceType {
    var writtenIndicies = [Int]()
    var lastExistsIndex: Int = -1
    for (index, source) in sources.enumerated() {
      let fileAlreadyExisted = try write(
        from: source,
        atContentPathURL: contentPathURL,
        basedOn: destinationURLGenerator,
        using: htmlToMarkdown,
        shouldOverwrite: options.contains(.shouldOverwriteExisting)
      )
      if fileAlreadyExisted {
        lastExistsIndex = index
      } else {
        writtenIndicies.append(index)
      }
    }

    if options.contains(.includeMissingPrevious) {
      return
    }

    for index in writtenIndicies where index < lastExistsIndex {
      let url = destinationURLGenerator.destinationURL(
        from: sources[index],
        atContentPathURL: contentPathURL
      )

      try FileManager.default.removeItem(at: url)
    }
  }
}
