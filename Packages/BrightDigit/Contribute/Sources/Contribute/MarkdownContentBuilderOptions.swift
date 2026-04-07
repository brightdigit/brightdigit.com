import Foundation

/// A type that represents the options that can be used when building markdown content.
public struct MarkdownContentBuilderOptions: OptionSet {
  public typealias RawValue = Int

  /// Specifies that any existing markdown content should be overwritten.
  internal static let shouldOverwriteExisting: Self = .init(rawValue: 1)

  /// Specifies that any missing previous markdown content should be included.
  internal static let includeMissingPrevious: Self = .init(rawValue: 2)

  public let rawValue: Int

  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
}

extension MarkdownContentBuilderOptions {
  /// Initializes a new  instance with the specified values.
  ///
  /// - Parameters:
  ///   - shouldOverwriteExisting: Specifies that any existing markdown content
  ///     should be overwritten.
  ///   - includeMissingPrevious: Specifies that any missing previous markdown content
  ///     should be included.
  public init(shouldOverwriteExisting: Bool, includeMissingPrevious: Bool) {
    self.init([
      includeMissingPrevious ? .includeMissingPrevious : .init(),
      shouldOverwriteExisting ? .shouldOverwriteExisting : .init()
    ])
  }
}
