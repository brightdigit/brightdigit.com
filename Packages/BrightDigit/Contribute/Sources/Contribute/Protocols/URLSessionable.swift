import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A protocol that defines a method for downloading data from a URL.
public protocol URLSessionable {
  /// Downloads data from the specified URL.
  ///
  /// - Parameters:
  ///   - fromURL: The URL from which the data should be downloaded.
  ///   - completion: A closure that is called when the download operation completes.
  ///   It takes three optional parameters: the downloaded data's URL, the URL response,
  ///   and any error that occurred during the download.
  func download(
    fromURL: URL,
    completion: @escaping @Sendable(URL?, URLResponse?, Error?) -> Void
  )
}

extension URLSession: URLSessionable {
  public func download(
    fromURL: URL,
    completion: @escaping @Sendable(URL?, URLResponse?, Error?) -> Void
  ) {
    downloadTask(with: fromURL, completionHandler: completion)
      .resume()
  }
}
