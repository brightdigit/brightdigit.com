import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A protocol that represents a type that generates a destination URL for a source data.
public protocol ContentURLGenerator {
  /// The type of the source data.
  associatedtype SourceType

  /// Returns the destination URL for the given source at the specified content path URL.
  ///
  /// - Parameters:
  ///   - source: An instance of `SourceType`.
  ///   - contentPathURL: A URL of the content path.
  /// - Returns: A URL of the destination.
  func destinationURL(
    from source: SourceType, atContentPathURL contentPathURL: URL
  ) -> URL
}
