import Contribute
import Foundation

public enum RSSError: ContributeError {
  case invalidRSS(URL)
  case invalidPodcastEpisodeFromRSSItem(String)
  case missingFieldFromPodcastEpisode(String, EpisodeField)

  public enum EpisodeField: Sendable {
    case duration
    case title
    case episode
    case summary
    case imageHref
    case link
  }
}
