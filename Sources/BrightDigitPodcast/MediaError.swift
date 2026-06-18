import Contribute

/// Errors raised while combining RSS audio episodes with their YouTube videos.
public enum MediaError: ContributeError {
  /// No YouTube video could be matched to the given RSS episode. A missing
  /// video is fatal: the import must not silently drop an episode from the site.
  case missingVideoForEpisode(episodeNo: Int, title: String)
}
