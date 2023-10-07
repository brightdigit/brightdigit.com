import Foundation
import Contribute
import SyndiKit

extension RSSContent {
  public struct Source {
    public let episodeNo: Int
    public let slug: String
    public let title: String
    public let date: Date
    public let summary: String
    public let content: String
    public let audioURL: URL
    public let imageURL: URL
    public let duration: TimeInterval
    public let podcastID: String

    public init(episodeNo: Int, slug: String, title: String, date: Date, summary: String, content: String, audioURL: URL, imageURL: URL, duration: TimeInterval, podcastID: String) {
      self.episodeNo = episodeNo
      self.slug = slug
      self.title = title
      self.date = date
      self.summary = summary
      self.content = content
      self.audioURL = audioURL
      self.imageURL = imageURL
      self.duration = duration
      self.podcastID = podcastID
    }
  }

}


extension RSSContent.Source {
  init (item : RSSItem,  id: KeyPath<RSSItem, String>) throws {
    guard let content = item.contentEncoded?.value ?? item.description?.value else {
      throw RSSError.invalidPodcastEpisodeFromRSSItem(item)
    }

    guard let date = item.published else {
      throw RSSError.invalidPodcastEpisodeFromRSSItem(item)
    }

    guard case let .podcast(episode) = item.media else {
      throw RSSError.invalidPodcastEpisodeFromRSSItem(item)
    }

    guard let duration = episode.duration else {
      throw RSSError.missingFieldFromPodcastEpisode(episode, .duration)
    }

    guard let title = episode.title else {
      throw RSSError.missingFieldFromPodcastEpisode(episode, .title)
    }

    guard let episodeNo = episode.episode else {
      throw RSSError.missingFieldFromPodcastEpisode(episode, .episode)
    }

    guard let summary = episode.summary?.firstSummaryParagraph() ?? episode.subtitle else {
      throw RSSError.missingFieldFromPodcastEpisode(episode, .summary)
    }

    guard let imageURL = episode.image?.href else {
      throw RSSError.missingFieldFromPodcastEpisode(episode, .imageHref)
    }

    let slug = title.slugify()
    
    guard episode.enclosure.type == "audio/mpeg" else {
      throw RSSError.missingFieldFromPodcastEpisode(episode, .episode)
    }
    
    let audioURL = episode.enclosure.url

    self.init(episodeNo: episodeNo, slug: slug, title: title, date: date, summary: summary, content: content, audioURL: audioURL, imageURL: imageURL, duration: duration, podcastID: item[keyPath: id])
  }
}
