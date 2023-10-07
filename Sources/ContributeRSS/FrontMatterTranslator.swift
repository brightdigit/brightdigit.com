import Foundation
import Contribute

public extension RSSContent {
  struct FrontMatterTranslator: Contribute.FrontMatterTranslator {
    public typealias SourceType = Source
    public typealias FrontMatterType = FrontMatter

    public struct FrontMatter: Codable {
      let title: String
      let date: String
      let description: String
      let featuredImage: URL
      let audioDuration: Int
      let podcastID: String

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
