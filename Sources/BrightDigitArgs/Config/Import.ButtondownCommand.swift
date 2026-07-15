//
//  Import.ButtondownCommand.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import BrightDigitSite
import ButtondownKit
import ConfigKeyKit
import Configuration
import Contribute
import ContributeButtondown
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Import.ButtondownCommand {
  /// Resolved configuration for the `import buttondown` command.
  public struct Config: ConfigurationParseable {
    public typealias ConfigReader = Configuration.ConfigReader
    public typealias BaseConfig = Never

    internal let exportMarkdownDirectory: String
    internal let buttondownAPIKey: String?
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

      // Optional: falls back to BUTTONDOWN_API_KEY via
      // `ButtondownClient.fromEnvironment()` when the flag is absent.
      self.buttondownAPIKey = reader.read(Keys.buttondownAPIKey)

      self.overwriteExisting = reader.read(Keys.overwriteExisting)
      self.includeMissingPrevious = reader.read(Keys.includeMissingPrevious)
    }
  }

  private enum Keys {
    static let exportMarkdownDirectory = OptionalConfigKey<String>(
      "export-markdown-directory"
    )
    static let buttondownAPIKey = OptionalConfigKey<String>(
      "buttondown-api-key"
    )
    static let overwriteExisting = ConfigKey(
      "overwrite-existing", default: false
    )
    static let includeMissingPrevious = ConfigKey(
      "include-missing-previous", default: false
    )
  }

  /// Lists sent Buttondown emails, assigns issue numbers continuing from the
  /// local archive, skips issues already on disk, and writes Markdown files for
  /// the new ones only.
  public func execute() async throws {
    let contentPathURL = URL(fileURLWithPath: config.exportMarkdownDirectory)
    let client = try Self.makeClient(apiKey: config.buttondownAPIKey)
    let htmlToMarkdown = Import.markdownGenerator.markdown(fromHTML:)

    // Only fully-sent emails are real published issues.
    let emails = try await client.listAllEmails(status: [.sent], pageLimit: nil)

    let existing = Self.existingIssueNumbers(in: contentPathURL)
    let localMax = existing.max() ?? 0
    let skip = config.overwriteExisting ? [] : existing

    let numbered = Newsletter.newIssues(
      from: emails,
      continuingFrom: localMax,
      existingIssueNumbers: skip
    )

    let alreadyPresent = emails.count - numbered.count
    if alreadyPresent > 0 {
      Self.logImport(
        "\(alreadyPresent) already on disk; importing \(numbered.count) new issue(s)."
      )
    }

    let sources = try numbered.map { try Self.source(from: $0) }
      .sorted { $0.issueNo < $1.issueNo }

    let options = MarkdownContentBuilderOptions(
      shouldOverwriteExisting: config.overwriteExisting,
      includeMissingPrevious: config.includeMissingPrevious
    )

    try Newsletter.write(
      from: sources,
      atContentPathURL: contentPathURL,
      fileNameWithoutExtension: Self.fileNameWithoutExtensionFromSource(_:),
      using: htmlToMarkdown,
      options: options
    )
  }
}

extension Import {
  /// ConfigKeyKit-based command for importing Buttondown newsletters (issue #122).
  ///
  /// Registers under the two-token name `import buttondown` and is dispatched by
  /// ``CommandDispatcher``. Lists the newsletter's sent emails, assigns each an
  /// issue number (continuing the local archive past issue 117), skips any issue
  /// already present locally, and writes `NNN-slug.md` for the new issues only.
  /// It writes ONLY local `Content/newsletters/*.md` — the operation is
  /// reversible with `git checkout`.
  public struct ButtondownCommand: ConfigKeyKit.Command {
    public static let commandName = "import buttondown"
    public static let abstract =
      "Command for importing newly-published Buttondown newsletters into the site."
    public static let helpText = """
      OVERVIEW: Import newly-published Buttondown newsletters into the BrightDigit site.

      USAGE: brightdigitwg import buttondown --export-markdown-directory <dir> \
      [--buttondown-api-key <key>] [--overwrite-existing] [--include-missing-previous]

      OPTIONS:
        --export-markdown-directory <dir> Destination directory for markdown files. \
      (required)
        --buttondown-api-key <key>        Buttondown API key. Falls back to the \
      BUTTONDOWN_API_KEY environment variable when omitted.
        --overwrite-existing              Overwrite existing markdown files.
        --include-missing-previous        Include newsletters missing a previous entry.
        -h, --help                        Show help information.

      Each option may also be supplied via an uppercased, underscore-separated
      environment variable (e.g. BUTTONDOWN_API_KEY).
      """

    private let config: Config

    public init(config: Config) {
      self.config = config
    }
  }
}
