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

  /// Builds a podcast source for each RSS item that has a matching video.
  ///
  /// Items for which `fetchVideo` returns `nil` are skipped rather than fatal,
  /// so one episode without a published video doesn't abort the whole import.
  public static func episodesBasedOn(
    rssItems: [AudioPodcastItem],
    fetchVideo: @escaping (AudioPodcastItem) -> VideoYouTubeItem?
  ) throws -> [BrightDigitPodcastSource] {
    try rssItems.compactMap { rssItem in
      guard let video = fetchVideo(rssItem) else {
        return nil
      }
      return try .init(
        podcastID: rssItem.podcastID,
        audio: rssItem,
        video: video
      )
    }
  }
}
