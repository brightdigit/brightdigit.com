import Foundation

public typealias BrightDigitPodcastSource = BrightDigitPodcast.Source

public extension BrightDigitPodcast {
  struct Source {
    public let episodeNo: Int
    public let slug: String
    public let title: String
    public let date: Date
    public let summary: String
    public let content: String
    public let media: Media

    public init(episodeNo: Int, slug: String, title: String, date: Date, summary: String, content: String, media: Media) {
      self.episodeNo = episodeNo
      self.slug = slug
      self.title = title
      self.date = date
      self.summary = summary
      self.content = content
      self.media = media
    }
  }
}
