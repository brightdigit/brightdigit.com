import Foundation

/// A protocol that defines file management methods.
public protocol FileManagerProtocol {
  /// Creates a directory at the specified URL.
  ///
  /// - Parameters:
  ///   - url: The URL of the directory to be created.
  ///   - createIntermediates: A boolean value indicating whether any nonexistent parent
  ///   directories should be created if they don't exist..
  ///   - attributes: An optional dictionary of file attributes to be applied.
  /// - Throws: An error if the directory creation fails.
  func createDirectory(
    at url: URL,
    withIntermediateDirectories createIntermediates: Bool,
    attributes: [FileAttributeKey: Any]?
  ) throws

  /// Checks whether a file exists at the specified path.
  ///
  /// - Parameter path: The file path to be checked.
  /// - Returns: `true` if the file exists, `false` otherwise.
  func fileExists(atPath path: String) -> Bool

  /// Copies a file or directory from the source URL to the destination URL.
  ///
  /// - Parameters:
  ///   - srcURL: The source URL of the item to be copied.
  ///   - dstURL: The destination URL where the item should be copied to.
  /// - Throws: An error if the copy operation fails.
  func copyItem(at srcURL: URL, to dstURL: URL) throws

  /// Removes a file or directory at the specified URL.
  ///
  /// - Parameter url: The URL of the item to be removed.
  /// - Throws: An error if the removal fails.
  func removeItem(at url: URL) throws
}

extension FileManagerProtocol {
  /// Creates a directory at the specified URL.
  /// By default, It will create any nonexistent parent directories if they don't exist..
  ///
  /// - Parameters:
  ///   - url: The URL of the directory to be created.
  ///   - createIntermediates: A boolean value indicating whether any nonexistent parent
  ///   directories should be created if they don't exist. Default value is `true`.
  /// - Throws: An error if the directory creation fails.
  public func createDirectory(
    at url: URL,
    withIntermediateDirectories createIntermediates: Bool = true
  ) throws {
    try createDirectory(
      at: url,
      withIntermediateDirectories: createIntermediates,
      attributes: nil
    )
  }
}

extension FileManager: FileManagerProtocol {}
