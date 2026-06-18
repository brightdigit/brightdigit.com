import BrightDigitSite
import ConfigKeyKit
import Configuration
import Foundation
import Publish

/// ConfigKeyKit-based command for generating the BrightDigit static site.
///
/// Part of the swift-argument-parser -> swift-configuration migration (issue #44).
/// Registers under the single-token name `publish` and is dispatched by
/// ``CommandDispatcher``. The required `--mode` option (or `MODE`)
/// selects between `drafts` (includes future-dated content) and `production`
/// (filters future-dated content).
public struct PublishCommand: ConfigKeyKit.Command {
  internal enum Mode: String, Sendable {
    case drafts, production
  }

  private enum Keys {
    static let mode = OptionalConfigKey<String>("mode")
  }

  public struct Config: ConfigurationParseable {
    public typealias ConfigReader = Configuration.ConfigReader
    public typealias BaseConfig = Never

    internal let mode: Mode

    public init(
      configuration reader: Configuration.ConfigReader,
      base _: Never?
    ) async throws {
      guard let modeString = reader.read(Keys.mode) else {
        throw CommandError.missingRequiredOption("--mode")
      }
      guard let mode = Mode(rawValue: modeString) else {
        throw CommandError.invalidValue(option: "--mode", value: modeString)
      }
      self.mode = mode
    }
  }

  public static let commandName = "publish"
  public static let abstract = "Command for generating the BrightDigit site."
  public static let helpText = """
    OVERVIEW: Command for generating the BrightDigit site.

    USAGE: brightdigitwg publish --mode <drafts|production>

    OPTIONS:
      --mode <mode>   Publishing mode: 'drafts' or 'production'. (required)
      -h, --help      Show help information.

    The --mode option may also be supplied via the MODE environment
    variable.
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

  public func execute() async throws {
    try await BrightDigitSite().publish(includeDrafts: config.mode == .drafts)
  }
}
