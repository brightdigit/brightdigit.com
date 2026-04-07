import Foundation

/// A protocol for generating Markdown from HTML.
public protocol MarkdownGenerator {
  /// Converts an HTML string to Markdown.
  ///
  /// - Parameter htmlString: The HTML string to convert.
  /// - Returns: The generated Markdown string.
  /// - Throws: An error if the conversion fails.
  func markdown(fromHTML htmlString: String) throws -> String
}
