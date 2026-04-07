import Foundation

public protocol BasicContentURLGenerator: ContentURLGenerator {
  /// Returns the file name (without extension) for the given source data.
  ///
  /// - Parameter source: The source data to generate the file name from.
  /// - Returns: A string representing the file name.
  func fileNameWithoutExtensionFromSource(_ source: SourceType) -> String
}

extension BasicContentURLGenerator {
  /// Returns a default destination URL for the given markdown source data.
  public func destinationURL(
    from source: SourceType, atContentPathURL contentPathURL: URL
  ) -> URL {
    let fileNameWithoutExtension = fileNameWithoutExtensionFromSource(source)

    return contentPathURL
      .appendingPathComponent(fileNameWithoutExtension)
      .appendingPathExtension("md")
  }
}
