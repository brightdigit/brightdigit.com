import ArgumentParser
import ContributeYouTube
import ContributeRSS
import Contribute
import BrightDigitPodcast
import Foundation
import SyndiKit

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif


extension RSSContent.Source : AudioPodcastItem {
  
}


extension YouTubeContent.Source : VideoYouTubeItem {
  
}

public extension BrightDigitSiteCommand.ImportCommand {
  struct Podcast: ParsableCommand {
    public static var configuration = CommandConfiguration(
      commandName: "podcast",
      abstract: "Command for importing a podcast into the BrightDigit site."
    )

    public init() {}

    @Option
    public var playlistID: String = "PLmpJxPaZbSnBvpnEdaX78wSM1d9BVvMfI"

    @Option
    public var youtubeAPIKey: String

    @Option
    public var rss = URL(string: "https://feeds.transistor.fm/empowerapps-show")!

    @Option(help: "Destination directory for markdown files.")
    public var exportMarkdownDirectory: String

    @Flag
    public var overwriteExisting: Bool = false

    @Flag
    public var includeMissingPrevious: Bool = false

    private static let markdownGenerator: MarkdownGenerator = BrightDigitSiteCommand.ImportCommand.markdownGenerator

    var contentPathURL: URL {
      URL(fileURLWithPath: exportMarkdownDirectory)
    }

    public func run() throws {
      let podcastEpisodes = try RSSContent.items(from: rss, id: \.link.lastPathComponent)
      let videos = try YouTubeContent.videos(
        byRequest: .init(
          apiKey: youtubeAPIKey,
          playlistID: playlistID
        )
      )
      let videoDurations = try YouTubeContent.videoDurations(videos)

      let episodes: [BrightDigitPodcastSource] = try Self.episodesBasedOn(
        rssItems: podcastEpisodes,
        withVideoDurations: videoDurations
      ).sorted(by: { lhs, rhs in lhs.episodeNo < rhs.episodeNo })

      let options: MarkdownContentBuilderOptions = .init(
        shouldOverwriteExisting: overwriteExisting,
        includeMissingPrevious: includeMissingPrevious
      )

      try BrightDigitPodcast.write(
        episodes: episodes,
        atContentPathURL: contentPathURL,
        using: Self.markdownGenerator.markdown(fromHTML:),
        options: options
      )
    }
    
    
    static func episodesBasedOn(
      rssItems: [RSSContent.Source],
      withVideoDurations videoDurations: VideoDurations
    ) throws -> [BrightDigitPodcastSource] {
      try BrightDigitPodcastSource
        .episodesBasedOn(
          rssItems: rssItems
        ) { rssItem in
              let title = rssItem.title.trimmingCharacters(in: .whitespacesAndNewlines)
              return videoDurations[title]
      }
    }
  }
}
