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

  /// An episode whose `fetchVideo` returns nil is skipped, not fatal — the rest
  /// of the import still completes.
  @Test internal func skipsEpisodesWithoutAVideoAndKeepsTheRest() throws {
    let items: [AudioPodcastItem] = [
      StubAudio(episodeNo: 1, slug: "one", title: "One", content: ""),
      StubAudio(episodeNo: 2, slug: "two", title: "Two", content: ""),
    ]

    let sources = try BrightDigitPodcast.Source.episodesBasedOn(
      rssItems: items
    ) { item in
      item.episodeNo == 1 ? StubVideo(youtubeID: "vid1") : nil
    }

    #expect(sources.count == 1)
    #expect(sources.first?.episodeNo == 1)
  }
}
