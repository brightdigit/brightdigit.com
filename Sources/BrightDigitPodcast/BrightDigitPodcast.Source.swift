import Foundation

public extension BrightDigitPodcast.Source {
  static func episodesBasedOn(
    rssItems: [AudioPodcastItem],
    fetchVideo: @escaping (AudioPodcastItem) -> VideoYouTubeItem?
  ) throws -> [BrightDigitPodcastSource] {
    try rssItems.map { rssItem in
      guard let video = fetchVideo(rssItem) else {
        throw MediaError.missingVideoForEpisode(rssItem)
      }
      return try .init(
        podcastID: rssItem.podcastID,
        audio: rssItem,
        video: video
      )
    }
  }
  
  init(
    podcastID: String,
    audio: AudioPodcastItem,
    video: VideoYouTubeItem
  ) throws {
    
    let media : BrightDigitPodcastMedia = .init(
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
  
}
