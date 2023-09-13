import Contribute
public extension LegacyPodcast {
  struct MarkdownExtractor: Contribute.MarkdownExtractor {
    public typealias SourceType = Source

    public init() {}

    public func markdown(from source: LegacyPodcast.Source, using _: @escaping (String) throws -> String) throws -> String {
      source.content
    }
  }
}
