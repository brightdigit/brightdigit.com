import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A protocol that downloads a content from a given URL.
public protocol URLDownloader {
  /// Downloads the content from the given URL to the given destination URL.
  ///
  /// - Parameters:
  ///   - fromURL: The URL of the content to download.
  ///   - toURL: The destination URL for the content.
  ///   - allowOverwrite: Whether to overwrite the destination URL if it already exists.
  ///   - completion: A completion handler that is called with the error, if any.
  func download(
    from fromURL: URL,
    to toURL: URL,
    allowOverwrite: Bool,
    _ completion: @escaping (Error?) -> Void
  )
}
