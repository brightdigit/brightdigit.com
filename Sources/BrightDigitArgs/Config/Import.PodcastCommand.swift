import BrightDigitPodcast
import ConfigKeyKit
import Configuration
import Contribute
import ContributeRSS
import ContributeYouTube
import Foundation
import SyndiKit

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Import.PodcastCommand {
  /// Resolved configuration for the `import podcast` command.
  public struct Config: ConfigurationParseable {
    public typealias ConfigReader = Configuration.ConfigReader
    public typealias BaseConfig = Never

    internal let playlistID: String
    internal let youtubeAPIKey: String
    internal let rss: URL
    internal let exportMarkdownDirectory: String
    internal let overwriteExisting: Bool
    internal let includeMissingPrevious: Bool

    public init(
      configuration reader: Configuration.ConfigReader,
      base _: Never?
    ) async throws {
      self.playlistID = reader.read(Keys.playlistID)

      guard let youtubeAPIKey = reader.read(Keys.youtubeAPIKey) else {
        throw CommandError.missingRequiredOption("--youtube-api-key")
      }
      self.youtubeAPIKey = youtubeAPIKey

      let rssString = reader.read(Keys.rss)
      guard let rss = URL(string: rssString) else {
        throw CommandError.invalidURL(rssString)
      }
      self.rss = rss

      guard let exportMarkdownDirectory = reader.read(Keys.exportMarkdownDirectory)
      else {
        throw CommandError.missingRequiredOption("--export-markdown-directory")
      }
      self.exportMarkdownDirectory = exportMarkdownDirectory

      self.overwriteExisting = reader.read(Keys.overwriteExisting)
      self.includeMissingPrevious = reader.read(Keys.includeMissingPrevious)
    }
  }

  private enum Keys {
    static let playlistID = ConfigKey(
      "playlist-id",
      default: "PLmpJxPaZbSnBvpnEdaX78wSM1d9BVvMfI"
    )
    static let youtubeAPIKey = OptionalConfigKey<String>(
      "youtube-api-key"
    )
    static let rss = ConfigKey(
      "rss",
      default: "https://feeds.transistor.fm/empowerapps-show"
    )
    static let exportMarkdownDirectory = OptionalConfigKey<String>(
      "export-markdown-directory"
    )
    static let overwriteExisting = ConfigKey(
      "overwrite-existing", default: false
    )
    static let includeMissingPrevious = ConfigKey(
      "include-missing-previous", default: false
    )
  }

  internal static func episodesBasedOn(
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

  public func execute() async throws {
    let contentPathURL = URL(fileURLWithPath: config.exportMarkdownDirectory)

    let podcastEpisodes = try RSSContent.items(from: config.rss) { item in
      guard let link = item.link else {
        throw RSSError.missingFieldFromPodcastEpisode(
          String(describing: item), .link
        )
      }
      return link.lastPathComponent
    }
    let videos = try await YouTubeContent.videos(
      byRequest: .init(
        apiKey: config.youtubeAPIKey,
        playlistID: config.playlistID
      )
    )
    let videoDurations = try YouTubeContent.videoDurations(videos)

    let episodes: [BrightDigitPodcastSource] =
      try Self.episodesBasedOn(
        rssItems: podcastEpisodes,
        withVideoDurations: videoDurations
      )
      .sorted(by: { lhs, rhs in lhs.episodeNo < rhs.episodeNo })

    let options: MarkdownContentBuilderOptions = .init(
      shouldOverwriteExisting: config.overwriteExisting,
      includeMissingPrevious: config.includeMissingPrevious
    )

    try BrightDigitPodcast.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      using: Import.markdownGenerator.markdown(fromHTML:),
      options: options
    )
  }
}

extension Import {
  /// ConfigKeyKit-based command for importing podcast episodes (issue #44).
  ///
  /// Registers under the two-token name `import podcast` and is dispatched by
  /// ``CommandDispatcher``. Pulls episodes from the Transistor RSS feed, enriches
  /// them with YouTube video durations, and writes Markdown episode files.
  public struct PodcastCommand: ConfigKeyKit.Command {
    public static let commandName = "import podcast"
    public static let abstract =
      "Command for importing a podcast into the BrightDigit site."
    public static let helpText = """
      OVERVIEW: Command for importing a podcast into the BrightDigit site.

      USAGE: brightdigitwg import podcast --youtube-api-key <key> \
      --export-markdown-directory <dir> [--playlist-id <id>] [--rss <url>] \
      [--overwrite-existing] [--include-missing-previous]

      OPTIONS:
        --playlist-id <id>                YouTube playlist ID.
        --youtube-api-key <key>           YouTube API key. (required)
        --rss <url>                       Podcast RSS feed URL.
        --export-markdown-directory <dir> Destination directory for markdown files. \
      (required)
        --overwrite-existing              Overwrite existing markdown files.
        --include-missing-previous        Include episodes missing a previous entry.
        -h, --help                        Show help information.

      Each option may also be supplied via an uppercased, underscore-separated
      environment variable (e.g. YOUTUBE_API_KEY).
      """

    private let config: Config

    public init(config: Config) {
      self.config = config
    }

    public static func createInstance() async throws -> Self {
      let reader = Configuration.ConfigReader(providers: [
        CommandLineArgumentsProvider(),
        EnvironmentVariablesProvider(),
      ])
      let config = try await Config(configuration: reader)
      return Self(config: config)
    }
  }
}

extension RSSContent.Source: AudioPodcastItem {
}

extension YouTubeContent.Source: VideoYouTubeItem {
}
