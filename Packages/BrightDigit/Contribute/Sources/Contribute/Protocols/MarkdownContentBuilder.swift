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
  public func write<ContentURLGeneratorType: ContentURLGenerator>(
    from source: SourceType,
    atContentPathURL contentPathURL: URL,
    basedOn destinationURLGenerator: ContentURLGeneratorType,
    using htmlToMarkdown: @escaping (String) throws -> String,
    shouldOverwrite: Bool = false
  ) throws -> Bool where ContentURLGeneratorType.SourceType == Self.SourceType {
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

  // swiftlint:disable function_body_length
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
  public func write<ContentURLGeneratorType: ContentURLGenerator>(
    from sources: [SourceType],
    atContentPathURL contentPathURL: URL,
    basedOn destinationURLGenerator: ContentURLGeneratorType,
    using htmlToMarkdown: @escaping (String) throws -> String,
    options: MarkdownContentBuilderOptions = []
  ) throws where ContentURLGeneratorType.SourceType == SourceType {
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

  // swiftlint:enable function_body_length
}
