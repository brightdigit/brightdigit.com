import Foundation
import Contribute

public enum MediaError: ContributeError {
  case missingVideoForEpisode(Any)
  case invalidPodcastEpisodeFromRSSItem(Any)
}
