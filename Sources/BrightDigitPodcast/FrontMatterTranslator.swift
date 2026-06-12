import Contribute
import Foundation

extension BrightDigitPodcast {
  public struct FrontMatterTranslator: Contribute.FrontMatterTranslator {
    public typealias SourceType = Source
    public typealias FrontMatterType = FrontMatter

    public struct FrontMatter: Codable {
      internal let title: String
      internal let date: String
      internal let description: String
      internal let featuredImage: URL
      internal let youtubeID: String
      internal let audioDuration: Int
      internal let videoDuration: Int
      internal let podcastID: String

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
