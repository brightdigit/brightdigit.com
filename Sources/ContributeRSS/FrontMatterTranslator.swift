import Contribute
import Foundation

extension RSSContent {
  public struct FrontMatterTranslator: Contribute.FrontMatterTranslator {
    public typealias SourceType = Source
    public typealias FrontMatterType = FrontMatter

    public struct FrontMatter: Codable {
      internal let title: String
      internal let date: String
      internal let description: String
      internal let featuredImage: URL
      internal let audioDuration: Int
      internal let podcastID: String

      public init(episode: Source) {
        title = episode.title
        date = YAML.dateFormatter.string(from: episode.date)
        description = episode.summary
        featuredImage = episode.imageURL
        audioDuration = Int(episode.duration)
        podcastID = episode.podcastID
      }
    }

    public init() {}

    public func frontMatter(from source: Source) -> FrontMatter {
      FrontMatter(episode: source)
    }
  }
}
