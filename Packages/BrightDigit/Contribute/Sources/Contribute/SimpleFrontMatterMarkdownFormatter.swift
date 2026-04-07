import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A simple formatter implementation for front matter and markdown together.
///
/// ```md
/// ---
/// title: WWDC 2018 - What Does It Mean For Businesses?
/// date: 2018-08-14 00:00
/// ---
/// <p>In this episode, we talk about <strong>WWDC 2018</strong></p>
/// ```
public struct SimpleFrontMatterMarkdownFormatter: FrontMatterMarkdownFormatter {
  /// Formats the given front matter text and markdown text into a single string.
  ///
  /// - Parameter frontMatterText: The front matter text.
  /// - Parameter markdownText: The markdown text.
  /// - Returns: The formatted string.
  public func format(
    frontMatterText: String,
    withMarkdown markdownText: String
  ) -> String {
    ["---", frontMatterText, "---", markdownText].joined(separator: "\n")
  }
}

extension FrontMatterMarkdownFormatter where Self == SimpleFrontMatterMarkdownFormatter {
  /// A static property that returns a `SimpleFrontMatterMarkdownFormatter` instance.
  public static var simple: SimpleFrontMatterMarkdownFormatter { .init() }
}
