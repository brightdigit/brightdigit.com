import Contribute
import Foundation

extension RSSContent {
  public struct MarkdownExtractor: Contribute.MarkdownExtractor {
    public typealias SourceType = Source

    public init() {}

    public func markdown(
      from source: SourceType,
      using _: @escaping (String) throws -> String
    ) throws -> String {
      source.content
    }
  }
}
