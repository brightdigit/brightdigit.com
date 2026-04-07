import Foundation

/// Closure based ``MarkdownGenerator``
public struct HTMLtoMarkdown: MarkdownGenerator {
  /// Closure to run to convert HTML to Markdown
  private let markdownFromHTML: (String) throws -> String

  /// Creates a ``MarkdownGenerator`` based on a closure
  ///
  /// - Parameter markdownFromHTML: The closure which returns Markdown from HTML.
  public init(_ markdownFromHTML: @escaping (String) throws -> String) {
    self.markdownFromHTML = markdownFromHTML
  }

  /// Converts an HTML string to Markdown.
  ///
  /// - Parameter htmlString: The HTML string to convert.
  /// - Returns: The generated Markdown string.
  /// - Throws: An error if the conversion fails.
  public func markdown(fromHTML htmlString: String) throws -> String {
    try markdownFromHTML(htmlString)
  }
}
