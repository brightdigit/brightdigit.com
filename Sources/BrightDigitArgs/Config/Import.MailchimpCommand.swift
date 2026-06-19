import BrightDigitSite
import ConfigKeyKit
import Configuration
import Contribute
import ContributeMailchimp
import Foundation
import Spinetail

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Import.MailchimpCommand {
  /// Resolved configuration for the `import mailchimp` command.
  public struct Config: ConfigurationParseable {
    public typealias ConfigReader = Configuration.ConfigReader
    public typealias BaseConfig = Never

    internal let exportMarkdownDirectory: String
    internal let mailchimpAPIKey: String
    internal let mailchimpListID: String
    internal let overwriteExisting: Bool
    internal let includeMissingPrevious: Bool

    public init(
      configuration reader: Configuration.ConfigReader,
      base _: Never?
    ) async throws {
      guard let exportMarkdownDirectory = reader.read(Keys.exportMarkdownDirectory)
      else {
        throw CommandError.missingRequiredOption("--export-markdown-directory")
      }
      self.exportMarkdownDirectory = exportMarkdownDirectory

      guard let mailchimpAPIKey = reader.read(Keys.mailchimpAPIKey) else {
        throw CommandError.missingRequiredOption("--mailchimp-api-key")
      }
      self.mailchimpAPIKey = mailchimpAPIKey

      guard let mailchimpListID = reader.read(Keys.mailchimpListID) else {
        throw CommandError.missingRequiredOption("--mailchimp-list-id")
      }
      self.mailchimpListID = mailchimpListID

      self.overwriteExisting = reader.read(Keys.overwriteExisting)
      self.includeMissingPrevious = reader.read(Keys.includeMissingPrevious)
    }
  }

  private enum Keys {
    static let exportMarkdownDirectory = OptionalConfigKey<String>(
      "export-markdown-directory"
    )
    static let mailchimpAPIKey = OptionalConfigKey<String>(
      "mailchimp-api-key"
    )
    static let mailchimpListID = OptionalConfigKey<String>(
      "mailchimp-list-id"
    )
    static let overwriteExisting = ConfigKey(
      "overwrite-existing", default: false
    )
    static let includeMissingPrevious = ConfigKey(
      "include-missing-previous", default: false
    )
  }

  public func execute() async throws {
    let contentPathURL = URL(fileURLWithPath: config.exportMarkdownDirectory)
    let client = try MailchimpClient(apiKey: config.mailchimpAPIKey)
    let htmlToMarkdown = Import.markdownGenerator.markdown(fromHTML:)

    let overwriteExisting = config.overwriteExisting
    let newsletters = try await Newsletter.sources(
      from: client,
      listID: config.mailchimpListID,
      selectingWith: {
        try Self.missingCampaigns(
          from: $0, in: contentPathURL, overwriteExisting: overwriteExisting
        )
      },
      processedWith: htmlToMarkdown
    )
    .sorted { $0.issueNo < $1.issueNo }

    let options = MarkdownContentBuilderOptions(
      shouldOverwriteExisting: config.overwriteExisting,
      includeMissingPrevious: config.includeMissingPrevious
    )

    try Newsletter.write(
      from: newsletters,
      atContentPathURL: contentPathURL,
      fileNameWithoutExtension: Self.fileNameWithoutExtensionFromSource(_:),
      using: htmlToMarkdown,
      options: options
    )
  }
}

extension Import {
  /// ConfigKeyKit-based command for importing Mailchimp newsletters (issue #44).
  ///
  /// Registers under the two-token name `import mailchimp` and is dispatched by
  /// ``CommandDispatcher``. Pulls campaigns from the configured Mailchimp list,
  /// filters them to BrightDigit newsletters, and writes Markdown newsletter files.
  public struct MailchimpCommand: ConfigKeyKit.Command {
    public static let commandName = "import mailchimp"
    public static let abstract =
      "Command for importing Mailchimp newsletters into the BrightDigit site."
    public static let helpText = """
      OVERVIEW: Command for importing Mailchimp newsletters into the BrightDigit site.

      USAGE: brightdigitwg import mailchimp --mailchimp-api-key <key> \
      --mailchimp-list-id <id> --export-markdown-directory <dir> \
      [--overwrite-existing] [--include-missing-previous]

      OPTIONS:
        --export-markdown-directory <dir> Destination directory for markdown files. \
      (required)
        --mailchimp-api-key <key>         Mailchimp API key. (required)
        --mailchimp-list-id <id>          Mailchimp list ID. (required)
        --overwrite-existing              Overwrite existing markdown files.
        --include-missing-previous        Include newsletters missing a previous entry.
        -h, --help                        Show help information.

      Each option may also be supplied via an uppercased, underscore-separated
      environment variable (e.g. MAILCHIMP_API_KEY).
      """

    private let config: Config

    public init(config: Config) {
      self.config = config
    }
  }
}
