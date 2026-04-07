import Foundation
import Yams

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A protocol that builds a YAML string from front matter object.
public protocol FrontMatterFormatter {
  /// Formats the front matter text into a YAML string.
  ///
  /// - Parameter frontMatter: The object containing front matter text.
  /// - Returns: The formatted YAML string.
  /// - Throws: An error if the front matter could not be processed.
  func format<FrontMatterType>(
    _ frontMatter: FrontMatterType
  ) throws -> String where FrontMatterType: Encodable
}

extension YAMLEncoder: FrontMatterFormatter {
  public func format<FrontMatterType>(
    _ frontMatter: FrontMatterType
  ) throws -> String where FrontMatterType: Encodable {
    try encode(frontMatter).trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
