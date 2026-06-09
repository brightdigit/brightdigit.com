import Foundation
import Contribute

public enum MediaError: ContributeError {
  case missingVideoForEpisode(String)
  case invalidPodcastEpisodeFromRSSItem(String)
}
