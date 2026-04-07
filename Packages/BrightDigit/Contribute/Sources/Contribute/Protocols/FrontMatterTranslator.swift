import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A protocol that converts source data to an encodable front matter component.
public protocol FrontMatterTranslator {
  /// The type of the source data.
  associatedtype SourceType

  /// The type of front matter to encode.
  associatedtype FrontMatterType: Encodable

  /// Initialize a new instance of `FrontMatterTranslator`.
  init()

  /// Convert source data to front matter.
  ///
  /// - Parameter source: The source data.
  /// - Returns: The resulting front matter.
  func frontMatter(from source: SourceType) -> FrontMatterType
}
