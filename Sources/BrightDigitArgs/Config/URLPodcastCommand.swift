import BrightDigitPodcast
import BrightDigitSite
import ConfigKeyKit
import Configuration
import Foundation

extension BrightDigitSiteCommand {
  /// ConfigKeyKit-based replacement for `BrightDigitSiteCommand.URLCommand.Podcast`.
  ///
  /// This is the first slice of the swift-argument-parser -> swift-configuration
  /// migration (see issue #44 and `Documentation/Migration/44-config-migration.md`).
  /// Each option is described once as a ``ConfigKeyKit/ConfigKey``, which yields
  /// both a CLI flag name (e.g. `--episode-number`) and a `BRIGHTDIGIT_`-prefixed
  /// environment variable name (e.g. `BRIGHTDIGIT_EPISODE_NUMBER`). The two names
  /// differ, so each source is resolved against its own
  /// ``Configuration/ConfigReader`` (CLI first, then environment) via
  /// ``ConfigSourceResolver``, with the per-key default as the final fallback.
  public struct URLPodcastCommand: ConfigKeyKit.Command {
    // ConfigKeyKit keys: one declaration drives both the CLI flag and env var.
    private enum Keys {
      static let baseURL = ConfigKey(
        "base-url",
        envPrefix: "BRIGHTDIGIT",
        default: BrightDigitSite.SiteInfo.url.absoluteString
      )
      static let basePath = ConfigKey(
        "base-path",
        envPrefix: "BRIGHTDIGIT",
        default: BrightDigitSite.SectionID.episodes.rawValue
      )
      static let episodeNumber = OptionalConfigKey<Int>(
        "episode-number", envPrefix: "BRIGHTDIGIT"
      )
      static let episodeTitle = OptionalConfigKey<String>(
        "episode-title", envPrefix: "BRIGHTDIGIT"
      )
    }

    public struct Config: ConfigurationParseable {
      public typealias ConfigReader = ConfigSourceResolver
      public typealias BaseConfig = Never

      public let baseURL: URL
      public let basePath: String
      public let episodeNumber: Int
      public let episodeTitle: String

      public init(
        configuration resolver: ConfigSourceResolver,
        base _: Never?
      ) async throws {
        let baseURLString =
          resolver.string(for: Keys.baseURL) ?? Keys.baseURL.defaultValue
        guard let baseURL = URL(string: baseURLString) else {
          throw URLPodcastError.invalidBaseURL(baseURLString)
        }
        self.baseURL = baseURL

        self.basePath =
          resolver.string(for: Keys.basePath) ?? Keys.basePath.defaultValue

        guard let episodeNumber = resolver.int(for: Keys.episodeNumber) else {
          throw URLPodcastError.missingRequiredOption("--episode-number")
        }
        self.episodeNumber = episodeNumber

        guard let episodeTitle = resolver.string(for: Keys.episodeTitle) else {
          throw URLPodcastError.missingRequiredOption("--episode-title")
        }
        self.episodeTitle = episodeTitle
      }
    }

    public static let commandName = "url podcast"
    public static let abstract =
      "Command for previewing urls for the BrightDigit site."
    public static let helpText = """
      OVERVIEW: Command for previewing urls for the BrightDigit site.

      USAGE: brightdigitwg url podcast --episode-number <n> \
      --episode-title <title> [--base-url <url>] [--base-path <path>]

      OPTIONS:
        --base-url <url>          Base URL. \
      (default: \(BrightDigitSite.SiteInfo.url.absoluteString))
        --base-path <path>        Base URL Path. \
      (default: \(BrightDigitSite.SectionID.episodes.rawValue))
        --episode-number <n>      Episode Number. (required)
        --episode-title <title>   Episode Title. (required)
        -h, --help                Show help information.

      Each option may also be supplied via environment variable using the
      BRIGHTDIGIT_ prefix (e.g. BRIGHTDIGIT_EPISODE_NUMBER).
      """

    private let config: Config

    public init(config: Config) {
      self.config = config
    }

    public static func createInstance() async throws -> Self {
      let config = try await Config(configuration: ConfigSourceResolver())
      return Self(config: config)
    }

    public func execute() async throws {
      let fileName = BrightDigitPodcast.fileNameWithoutExtensionForEpisode(
        withNumber: config.episodeNumber,
        title: config.episodeTitle
      )
      let url = config.baseURL
        .appendingPathComponent(config.basePath)
        .appendingPathComponent(fileName)
      print(url)
    }
  }
}
