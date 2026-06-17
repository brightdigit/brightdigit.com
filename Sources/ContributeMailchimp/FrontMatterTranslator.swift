import Contribute

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Newsletter {
  /// Translates a newsletter ``Source`` into its ``FrontMatter``.
  public struct FrontMatterTranslator: Contribute.FrontMatterTranslator {
    public typealias FrontMatterType = FrontMatter
    public typealias SourceType = Source

    public init() {}

    public func frontMatter(from source: Source) -> FrontMatter {
      FrontMatter(
        issueNo: source.issueNo,
        campaignID: source.campaignID,
        featuredImage: source.featuredImageURL,
        longArchiveURL: source.longArchiveURL,
        newsletterTitle: source.title,
        title: source.subjectLine,
        date: YAML.dateFormatter.string(from: source.sendTime),
        description: source.previewText
      )
    }
  }
}
