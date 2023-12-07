import Foundation
import Contribute

public extension BrightDigitPodcast {
  struct FrontMatterTranslator: Contribute.FrontMatterTranslator {
    public typealias SourceType = Source
    public typealias FrontMatterType = FrontMatter

    public struct FrontMatter: Codable {
      let title: String
      let date: String
      let description: String
      let featuredImage: URL
      let youtubeID: String
      let audioDuration: Int
      let videoDuration: Int
      let podcastID: String

      public init(episode: SourceType) {
        title = episode.title
        date = YAML.dateFormatter.string(from: episode.date)
        description = episode.summary
        featuredImage = episode.media.imageURL
        youtubeID = episode.media.youtubeID
        audioDuration = Int(episode.media.podcastDuration)
        videoDuration = Int(episode.media.youtubeDuration)
        podcastID = episode.media.podcastID
      }
    }

    public init() {}

    public func frontMatter(from source: SourceType) -> FrontMatterType {
      FrontMatter(episode: source)
    }
  }
}
