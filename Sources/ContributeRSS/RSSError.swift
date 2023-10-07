import Foundation
import Contribute

public enum RSSError: ContributeError {
  case invalidRSS(URL)
  case invalidPodcastEpisodeFromRSSItem(Any)
  case missingFieldFromPodcastEpisode(Any, EpisodeField)

  public enum EpisodeField {
    case duration
    case title
    case episode
    case summary
    case imageHref
  }
}
