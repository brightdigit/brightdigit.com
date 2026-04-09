import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A protocol that exports front matter from a source data.
public protocol FrontMatterExporter {
  /// The type of the source data.
  associatedtype SourceType

  /// Exports the front matter text from the given source data.
  ///
  /// - Parameter source: The source data to export front matter from.
  /// - Returns: The exported front matter text.
  /// - Throws: An error if the source data could not be processed.
  func frontMatterText(from source: SourceType) throws -> String
}
