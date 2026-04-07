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
  ///   - using: A function that converts HTML to markdown.
  ///   - options: The options for the markdown content builder.
  /// - Throws: An error if the sources could not be written.
  ///
  /// - Note: The `destinationURLGenerator` function must be able to generate
  ///   destination URLs for all of the sources in the `sources` array.
  public static func write<ContentURLGeneratorType: ContentURLGenerator>(
    from sources: [SourceType],
    atContentPathURL contentPathURL: URL,
    basedOn destinationURLGenerator: ContentURLGeneratorType,
    using htmlToMarkdown: @escaping (String) throws -> String,
    options: MarkdownContentBuilderOptions = []
  ) throws where ContentURLGeneratorType.SourceType == Self.SourceType {
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
  ///   - using: A function that converts HTML to Markdown.
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
