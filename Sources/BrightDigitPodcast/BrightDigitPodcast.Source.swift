import Foundation

extension BrightDigitPodcast.Source {
  public init(
    podcastID: String,
    audio: AudioPodcastItem,
    video: VideoYouTubeItem
  ) throws {
    let media: BrightDigitPodcastMedia = .init(
      youtubeID: video.youtubeID,
      videoDuration: video.duration,
      podcastID: audio.podcastID,
      audioDuration: audio.duration,
      audioURL: audio.audioURL,
      imageURL: audio.imageURL
    )
    self.init(
      episodeNo: audio.episodeNo,
      slug: audio.slug,
      title: audio.title,
      date: audio.date,
      summary: audio.summary,
      content: audio.content,
      media: media
    )
  }

  /// Builds a podcast source for every RSS item, pairing it with its video.
  ///
  /// A missing video is fatal: if `fetchVideo` returns `nil` for any item this
  /// throws ``MediaError/missingVideoForEpisode(episodeNo:title:)`` rather than
  /// silently dropping the episode, so the import never publishes a site that is
  /// missing an episode without anyone noticing.
  public static func episodesBasedOn(
    rssItems: [AudioPodcastItem],
    fetchVideo: @escaping (AudioPodcastItem) -> VideoYouTubeItem?
  ) throws -> [BrightDigitPodcastSource] {
    try rssItems.map { rssItem in
      guard let video = fetchVideo(rssItem) else {
        throw MediaError.missingVideoForEpisode(
          episodeNo: rssItem.episodeNo,
          title: rssItem.title
        )
      }
      return try .init(
        podcastID: rssItem.podcastID,
        audio: rssItem,
        video: video
      )
    }
  }
}
