// swiftlint
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A struct that downloads files from URLs using the `URLSession` class, or .
public struct FileURLDownloader: URLDownloader {
  private let networkManager: URLSessionable
  private let fileManager: FileManagerProtocol

  /// Initializes the downloader with the given `URLSession` and `FileManager` instances.
  ///
  /// - Parameters:
  ///   - session: The `URLSession` instance to use for downloading files.
  ///   - fileManager: The `FileManager` instance to use for saving downloaded files.
  public init(
    networkManager: URLSessionable = URLSession.shared,
    fileManager: FileManagerProtocol = FileManager.default
  ) {
    self.networkManager = networkManager
    self.fileManager = fileManager
  }

  /// Downloads the file from the given URL to the given destination URL.
  ///
  /// - Parameters:
  ///   - fromURL: The URL of the file to download.
  ///   - toURL: The destination URL for the file.
  ///   - allowOverwrite: Whether to overwrite the destination file if it already exists.
  ///   - completion: A completion handler that is called with the error, if any.
  public func download(
    from fromURL: URL,
    to toURL: URL,
    allowOverwrite: Bool,
    _ completion: @escaping (Error?) -> Void
  ) {
    if fromURL.isFileURL {
      downloadFromLocal(
        from: fromURL,
        to: toURL,
        allowOverwrite: allowOverwrite,
        completion
      )
    } else {
      downloadFromNetwork(
        from: fromURL,
        to: toURL,
        allowOverwrite: allowOverwrite,
        completion
      )
    }
  }

  private func downloadFromNetwork(
    from fromURL: URL,
    to toURL: URL,
    allowOverwrite: Bool,
    _ completion: @escaping (Error?) -> Void
  ) {
    networkManager.download(fromURL: fromURL) { destination, _, error in
      guard let sourceURL = destination else {
        return completion(error)
      }

      downloadFromLocal(
        from: sourceURL,
        to: toURL,
        allowOverwrite: allowOverwrite,
        completion
      )
    }
  }

  private func downloadFromLocal(
    from fromURL: URL,
    to toURL: URL,
    allowOverwrite: Bool,
    _ completion: @escaping (Error?) -> Void
  ) {
    do {
      // Create directory for the destination URL.
      try fileManager.createDirectory(at: toURL.deletingLastPathComponent())

      let fileExists = fileManager.fileExists(atPath: toURL.path)

      // Check if the destination file already exists so to overwrite it,
      // Otherwise just write the sourceURL at the give destination URL.

      if !fileExists {
        try fileManager.copyItem(at: fromURL, to: toURL)
      } else if allowOverwrite, fileExists {
        try fileManager.removeItem(at: toURL)
        try fileManager.copyItem(at: fromURL, to: toURL)
      }

      completion(nil)
    } catch {
      completion(error)
    }
  }
}
