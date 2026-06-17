import Contribute

extension Newsletter {
  /// Extracts the already-rendered Markdown body from a newsletter ``Source``.
  public struct MarkdownExtractor: Contribute.MarkdownExtractor {
    public typealias SourceType = Source

    public init() {}

    public func markdown(
      from source: Newsletter.Source,
      using _: @escaping (String) throws -> String
    ) throws -> String {
      source.markdown
    }
  }
}
