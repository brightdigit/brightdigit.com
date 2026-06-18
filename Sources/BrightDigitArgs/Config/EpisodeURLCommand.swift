import BrightDigitPodcast
import BrightDigitSite
import ConfigKeyKit
import Configuration
import Foundation

/// ConfigKeyKit-based command for previewing a podcast episode's URL.
///
/// This is the first slice of the swift-argument-parser -> swift-configuration
/// migration (see issue #44 and `Documentation/Migration/44-config-migration.md`).
/// It registers with ``ConfigKeyKit/CommandRegistry`` under the two-token name
/// `url podcast` and is dispatched by ``CommandDispatcher``. Each option is
/// described once as a ``ConfigKeyKit/ConfigKey``, which yields both a CLI flag
/// name (e.g. `--episode-number`) and an uppercased, underscore-separated
/// environment variable name (e.g. `EPISODE_NUMBER`). A single
/// ``Configuration/ConfigReader`` (CLI first, then environment) resolves every
/// key via ConfigKeyKit's ``ConfigKeyKit/ConfigValueReading/read(_:)``, with the
/// per-key default as the final fallback.
public struct EpisodeURLCommand: ConfigKeyKit.Command {
  // ConfigKeyKit keys: one declaration drives both the CLI flag and env var.
  private enum Keys {
    static let baseURL = ConfigKey(
      "base-url",
      default: BrightDigitSite.SiteInfo.url.absoluteString
    )
    static let basePath = ConfigKey(
      "base-path",
      default: BrightDigitSite.SectionID.episodes.rawValue
    )
    static let episodeNumber = OptionalConfigKey<Int>(
      "episode-number"
    )
    static let episodeTitle = OptionalConfigKey<String>(
      "episode-title"
    )
  }

  public struct Config: ConfigurationParseable {
    public typealias ConfigReader = Configuration.ConfigReader
    public typealias BaseConfig = Never

    public let baseURL: URL
    public let basePath: String
    public let episodeNumber: Int
    public let episodeTitle: String

    public init(
      configuration reader: Configuration.ConfigReader,
      base _: Never?
    ) async throws {
      let baseURLString = reader.read(Keys.baseURL)
      guard let baseURL = URL(string: baseURLString) else {
        throw CommandError.invalidURL(baseURLString)
      }
      self.baseURL = baseURL

      self.basePath = reader.read(Keys.basePath)

      guard let episodeNumber = reader.read(Keys.episodeNumber) else {
        throw CommandError.missingRequiredOption("--episode-number")
      }
      self.episodeNumber = episodeNumber

      guard let episodeTitle = reader.read(Keys.episodeTitle) else {
        throw CommandError.missingRequiredOption("--episode-title")
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

    Each option may also be supplied via an uppercased, underscore-separated
    environment variable (e.g. EPISODE_NUMBER).
    """

  private let config: Config

  public init(config: Config) {
    self.config = config
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
