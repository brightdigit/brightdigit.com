import BrightDigitSite
import ConfigKeyKit
import Configuration
import ContributeWordPress
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// ConfigKeyKit-based command for importing a WordPress export (issue #44).
///
/// Registers under the two-token name `import wordpress` and is dispatched by
/// ``CommandDispatcher``. Processes a WordPress export directory into Markdown
/// articles, optionally downloading or copying referenced assets.
public struct ImportWordPressCommand: ConfigKeyKit.Command {
  private enum Keys {
    static let wordpressExportsDirectory = OptionalConfigKey<String>(
      "wordpress-exports-directory"
    )
    static let importAssetsDirectory = OptionalConfigKey<String>(
      "import-assets-directory"
    )
    static let assetRelativePath = ConfigKey(
      "asset-relative-path", default: "media/wp-images"
    )
    static let overwriteAssets = ConfigKey(
      "overwrite-assets", default: false
    )
    static let skipDownload = ConfigKey(
      "skip-download", default: false
    )
  }

  public static let commandName = "import wordpress"
  public static let abstract =
    "Command for importing a WordPress export into the BrightDigit site."
  public static let helpText = """
    OVERVIEW: Command for importing a WordPress export into the BrightDigit site.

    USAGE: brightdigitwg import wordpress --wordpress-exports-directory <dir> \
    [--import-assets-directory <dir>] [--asset-relative-path <path>] \
    [--overwrite-assets] [--skip-download]

    OPTIONS:
      --wordpress-exports-directory <dir> Directory containing one or more imports. \
    (required)
      --import-assets-directory <dir>     Directory containing images, PDFs, and \
    other assets.
      --asset-relative-path <path>        Path to save images relative to resources.
      --overwrite-assets                  Overwrite downloaded assets.
      --skip-download                     Skip downloading assets.
      -h, --help                          Show help information.

    Each option may also be supplied via an uppercased, underscore-separated
    environment variable (e.g. WORDPRESS_EXPORTS_DIRECTORY).
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
    let processor = try MarkdownProcessor(postFilters: [
      RegexKeyPostFilter(pattern: "post", keyPath: \.type),
      RegexKeyPostFilter(pattern: "^empowerapps-show", keyPath: \.name, not: true),
      RegexKeyPostFilter(pattern: "^$", keyPath: \.name, not: true),
      RegexKeyPostFilter(pattern: "publish", keyPath: \.status),
    ])

    let settings = Settings(
      rootPublishSiteURL: config.rootPublishPathURL,
      exportsDirectoryURL: config.exportsDirectoryURL,
      assetImportSetting: config.assetImportSetting,
      overwriteAssets: config.overwriteAssets,
      assetRelativePath: config.assetRelativePath
    )

    try processor.begin(withSettings: settings)
  }
}

extension ImportWordPressCommand {
  /// Resolved configuration for the `import wordpress` command.
  public struct Config: ConfigurationParseable {
    public typealias ConfigReader = Configuration.ConfigReader
    public typealias BaseConfig = Never

    internal let wordpressExportsDirectory: String
    internal let importAssetsDirectory: String?
    internal let assetRelativePath: String
    internal let overwriteAssets: Bool
    internal let skipDownload: Bool

    internal var rootPublishPathURL: URL {
      URL(
        fileURLWithPath: "",
        relativeTo: FileManager.default.currentDirectoryURL
      )
    }

    internal var exportsDirectoryURL: URL {
      URL(
        fileURLWithPath: wordpressExportsDirectory,
        relativeTo: FileManager.default.currentDirectoryURL
      )
    }

    internal var assetImportSetting: AssetImportSetting {
      switch (importAssetsDirectory, skipDownload) {
      case (.some(let directory), _):
        return .copyFilesFrom(
          .init(
            fileURLWithPath: directory,
            relativeTo: FileManager.default.currentDirectoryURL
          )
        )
      case (.none, true):
        return .none
      default:
        return .download
      }
    }

    public init(
      configuration reader: Configuration.ConfigReader,
      base _: Never?
    ) async throws {
      guard
        let wordpressExportsDirectory = reader.read(Keys.wordpressExportsDirectory)
      else {
        throw CommandError.missingRequiredOption("--wordpress-exports-directory")
      }
      self.wordpressExportsDirectory = wordpressExportsDirectory
      self.importAssetsDirectory = reader.read(Keys.importAssetsDirectory)
      self.assetRelativePath = reader.read(Keys.assetRelativePath)
      self.overwriteAssets = reader.read(Keys.overwriteAssets)
      self.skipDownload = reader.read(Keys.skipDownload)
    }
  }
}
