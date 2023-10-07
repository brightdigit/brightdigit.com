import Contribute
import Foundation

public extension YouTubeContent {
  struct FrontMatterTranslator: Contribute.FrontMatterTranslator {
    public typealias SourceType = Source
    public typealias FrontMatterType = FrontMatter

    public struct FrontMatter: Codable {
      let title: String
      let date: String
      let featuredImage: URL?
      let youtubeID: String
      let videoDuration: Int

      public init(episode: Source) {
        title = episode.title
        date = YAML.dateFormatter.string(from: episode.date)
        featuredImage = episode.imageURL
        youtubeID = episode.youtubeID
        videoDuration = Int(episode.duration)
      }
    }

    public init() {}

    public func frontMatter(from source: Source) -> FrontMatter {
      FrontMatter(episode: source)
    }
  }

}
