// swift-format-ignore-file
// swiftlint:disable all
import Foundation
import Contribute

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public extension YouTubeContent {
  struct MarkdownExtractor: Contribute.MarkdownExtractor {
    public typealias SourceType = Source

    public init() {}

    public func markdown(
      from source: SourceType,
      using _: @escaping (String) throws -> String
    ) throws -> String {
      source.description
    }
  }
}
