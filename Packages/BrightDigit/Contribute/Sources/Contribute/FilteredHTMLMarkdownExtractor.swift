import Foundation

/// A type that extracts HTML content from markdown.
public struct FilteredHTMLMarkdownExtractor<SourceType: HTMLSource>: MarkdownExtractor {
  public init() {}

  /// Convert the HTML content to markdown.
  ///
  /// - Parameters:
  ///   - source: The HTML content source.
  ///   - htmlToMarkdown: Converter for processing the HTML.
  /// - Returns: The resulting markdown.
  public func markdown(
    from source: SourceType,
    using htmlToMarkdown: @escaping (String) throws -> String
  ) throws -> String {
    try htmlToMarkdown(source.html)
  }
}
