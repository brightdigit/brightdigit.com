import Foundation
import Testing

@testable import BrightDigitPodcast

internal struct PodcastMatchingTests {
  private struct StubAudio: AudioPodcastItem {
    let podcastID = "pod"
    let episodeNo: Int
    let slug: String
    let title: String
    let date = Date(timeIntervalSince1970: 0)
    let summary = ""
    let content: String
    let duration: TimeInterval = 100
    let imageURL = URL(fileURLWithPath: "/image.png")
    let audioURL = URL(fileURLWithPath: "/audio.mp3")
  }

  private struct StubVideo: VideoYouTubeItem {
    let youtubeID: String
    let duration: TimeInterval = 200
  }

  /// An episode without a matching video is fatal: the import must not silently
  /// drop an episode, so `episodesBasedOn` throws rather than returning a short
  /// list.
  @Test internal func throwsWhenAnEpisodeHasNoMatchingVideo() {
    let items: [AudioPodcastItem] = [
      StubAudio(episodeNo: 1, slug: "one", title: "One", content: ""),
      StubAudio(episodeNo: 2, slug: "two", title: "Two", content: ""),
    ]

    #expect(throws: MediaError.self) {
      try BrightDigitPodcast.Source.episodesBasedOn(rssItems: items) { item in
        item.episodeNo == 1 ? StubVideo(youtubeID: "vid1") : nil
      }
    }
  }

  /// When every episode has a matching video, all sources are built.
  @Test internal func buildsASourceForEveryMatchedEpisode() throws {
    let items: [AudioPodcastItem] = [
      StubAudio(episodeNo: 1, slug: "one", title: "One", content: ""),
      StubAudio(episodeNo: 2, slug: "two", title: "Two", content: ""),
    ]

    let sources = try BrightDigitPodcast.Source.episodesBasedOn(
      rssItems: items
    ) { item in
      StubVideo(youtubeID: "vid\(item.episodeNo)")
    }

    #expect(sources.map(\.episodeNo) == [1, 2])
  }
}
