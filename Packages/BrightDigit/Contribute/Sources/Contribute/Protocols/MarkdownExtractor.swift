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
