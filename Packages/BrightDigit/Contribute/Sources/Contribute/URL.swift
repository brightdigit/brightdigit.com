import Foundation

extension URL {
  /// The URL for the temporary directory.
  ///
  /// - Note: This URL is created using the `NSTemporaryDirectory()` function,
  /// which returns the path to the temporary directory on the current device.
  /// The `isDirectory` parameter is set to `true` to indicate that the URL represents
  /// a directory.
  public static let temporaryDirURL = URL(
    fileURLWithPath: NSTemporaryDirectory(),
    isDirectory: true
  )
}
