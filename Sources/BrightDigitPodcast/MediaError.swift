import Contribute
import Foundation

public enum MediaError: ContributeError {
  case missingVideoForEpisode(String)
  case invalidPodcastEpisodeFromRSSItem(String)
}
