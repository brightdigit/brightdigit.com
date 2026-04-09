import Foundation

/// A struct that generates a destination URL for a source data by taking the file name
/// without extension from the source data.
///
/// - SeeAlso: `ContentURLGenerator`, `BasicContentURLGenerator`
public struct FileNameGenerator<SourceType>: BasicContentURLGenerator {
  /// The action that generates the file name without extension from the source data.
  private let fileNameWithoutExtensionAction: (SourceType) -> String

  /// Initializes a `FileNameGenerator` with the given action that generates the file name
  /// without extension from the source data.
  ///
  /// - Parameter fileNameWithoutExtensionFromSource: The action that generates
  /// the file name without extension from the source data.
  public init(_ fileNameWithoutExtensionFromSource: @escaping (SourceType) -> String) {
    fileNameWithoutExtensionAction = fileNameWithoutExtensionFromSource
  }

  /// Returns the file name (without extension) for the given source data.
  ///
  /// - Parameter source: The source data to generate the file name from.
  /// - Returns: A string representing the file name without extension.
  ///
  /// - SeeAlso: `BasicContentURLGenerator.fileNameWithoutExtensionFromSource`
  public func fileNameWithoutExtensionFromSource(_ source: SourceType) -> String {
    fileNameWithoutExtensionAction(source)
  }
}
