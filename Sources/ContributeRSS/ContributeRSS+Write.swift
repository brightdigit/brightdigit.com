import Foundation
import Contribute

public extension RSSContent {
  static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
    Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try self.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      using: htmlToMarkdown,
      markdownExtractorType: Self.MarkdownExtractorType.self,
      frontMatterTranslatorType: Self.FrontMatterTranslatorType.self
    )
  }

  static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
    Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    markdownExtractorType: MarkdownExtractorType.Type,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try self.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      using: htmlToMarkdown,
      markdownExtractorType: markdownExtractorType,
      frontMatterTranslatorType: Self.FrontMatterTranslatorType.self
    )
  }

  static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
    Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    frontMatterTranslatorType: FrontMatterTranslatorType.Type,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try self.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      using: htmlToMarkdown,
      markdownExtractorType: Self.MarkdownExtractorType.self,
      frontMatterTranslatorType: frontMatterTranslatorType
    )
  }

  static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
    Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    markdownExtractorType: MarkdownExtractorType.Type,
    frontMatterTranslatorType: FrontMatterTranslatorType.Type,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try write(
      from: episodes,
      atContentPathURL: contentPathURL,
      fileNameWithoutExtension: fileNameWithoutExtension,
      using: htmlToMarkdown,
      options: options
    )
  }

  static func fileNameWithoutExtensionFromSource(
    _ source: SourceType
  ) -> String {
    source.slug
  }
}
