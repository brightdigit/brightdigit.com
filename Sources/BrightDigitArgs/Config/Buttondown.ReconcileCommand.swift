//
//  Buttondown.ReconcileCommand.swift
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

import ButtondownKit
import ConfigKeyKit
import Configuration
import Foundation

extension Buttondown.ReconcileCommand {
  /// Resolved configuration for the `buttondown reconcile` command.
  public struct Config: ConfigurationParseable {
    public typealias ConfigReader = Configuration.ConfigReader
    public typealias BaseConfig = Never

    internal let mailchimpAPIKey: String
    internal let mailchimpListID: String
    internal let buttondownAPIKey: String?
    internal let execute: Bool
    internal let previewDirectory: String?
    internal let minBodyWords: Int

    public init(
      configuration reader: Configuration.ConfigReader,
      base _: Never?
    ) async throws {
      guard let mailchimpAPIKey = reader.read(Keys.mailchimpAPIKey) else {
        throw CommandError.missingRequiredOption("--mailchimp-api-key")
      }
      self.mailchimpAPIKey = mailchimpAPIKey

      guard let mailchimpListID = reader.read(Keys.mailchimpListID) else {
        throw CommandError.missingRequiredOption("--mailchimp-list-id")
      }
      self.mailchimpListID = mailchimpListID

      self.buttondownAPIKey = reader.read(Keys.buttondownAPIKey)
      // Read this through swift-configuration's native Boolean API so a bare
      // `--execute` flag is recognized. ConfigKeyKit's string-based Boolean
      // bridge cannot observe CLI flags because they intentionally have no
      // string value.
      self.execute = reader.bool(
        forKey: Configuration.ConfigKey("execute"),
        default: false
      )
      self.previewDirectory = reader.read(Keys.previewDirectory)
      self.minBodyWords = reader.read(Keys.minBodyWords)
      _ = try Buttondown.ReconcileCommand.mode(
        execute: execute,
        previewDirectory: previewDirectory
      )
    }

    /// Builds the Buttondown client: an explicit `--buttondown-api-key` if
    /// supplied, else the `BUTTONDOWN_API_KEY` environment fallback.
    internal func makeButtondownClient() throws -> ButtondownClient {
      if let buttondownAPIKey {
        return ButtondownClient(apiKey: buttondownAPIKey)
      }
      return try ButtondownClient.fromEnvironment()
    }
  }

  private enum Keys {
    static let mailchimpAPIKey = OptionalConfigKey<String>("mailchimp-api-key")
    static let mailchimpListID = OptionalConfigKey<String>("mailchimp-list-id")
    static let buttondownAPIKey = OptionalConfigKey<String>("buttondown-api-key")
    static let previewDirectory = OptionalConfigKey<String>("preview-directory")
    /// Minimum meaningful word count a cleaned body must have to be written.
    ///
    /// Modern Mailchimp/Buttondown template issues clean down to near-empty
    /// skeletons (images + empty links); this gate skips them so reconcile never
    /// overwrites an archive body with less than it had. `0` disables the gate.
    static let minBodyWords = ConfigKey("min-body-words", default: 100)
  }
}

extension Buttondown {
  /// ConfigKeyKit-based command for reconciling the Buttondown newsletter
  /// archive against Mailchimp (issue #127).
  ///
  /// Registers under the two-token name `buttondown reconcile` and is dispatched
  /// by ``CommandDispatcher``. Reads sent campaigns from Mailchimp (via
  /// Spinetail) and the current emails from Buttondown, derives an issue number
  /// for each, and plans an UPDATE (cleaned body) for every issue already present
  /// as an imported archive email. It **only ever updates**: issues absent from
  /// Buttondown are reported and skipped (never created), non-imported emails are
  /// never touched, and issues whose cleaned body falls under `--min-body-words`
  /// are skipped so a template issue that cleans to an empty skeleton can't
  /// overwrite a fuller archive body. Every invocation must choose exactly one
  /// mode: `--preview-directory` exports reviewable Markdown without Buttondown
  /// writes, while `--execute` applies updates. It never touches local
  /// `Content/newsletters/*.md`.
  public struct ReconcileCommand: ConfigKeyKit.Command {
    public static let commandName = "buttondown reconcile"
    public static let abstract =
      "Preview or execute Buttondown reconciliation against Mailchimp."
    public static let helpText = """
      OVERVIEW: Reconcile the Buttondown newsletter archive against Mailchimp.

      Reads sent campaigns from Mailchimp (via Spinetail) and current emails from
      Buttondown, then plans an UPDATE (cleaned body) for each issue already
      present as an imported archive email. Updates only: absent issues are
      reported and skipped (never created), non-imported emails are never
      touched, and issues whose cleaned body is under --min-body-words are
      skipped. Exactly one of --preview-directory or --execute is required;
      local Content/newsletters/*.md files are never touched.

      USAGE: brightdigitwg buttondown reconcile --mailchimp-api-key <key> \
      --mailchimp-list-id <id> [--buttondown-api-key <key>] \
      [--min-body-words <n>] \
      (--execute | --preview-directory <path>)

      OPTIONS:
        --mailchimp-api-key <key>   Mailchimp API key. (required)
        --mailchimp-list-id <id>    Mailchimp list ID. (required)
        --buttondown-api-key <key>  Buttondown API key; falls back to env.
        --min-body-words <n>        Skip thin bodies; default 100, 0 disables.
        --preview-directory <path>  Export converted Markdown without writing.
        --execute                   Apply the plan to Buttondown.
        -h, --help                  Show help information.

      Each option may also be supplied via an uppercased, underscore-separated
      environment variable (e.g. MAILCHIMP_API_KEY, BUTTONDOWN_API_KEY).
      """

    internal let config: Config

    public init(config: Config) {
      self.config = config
    }
  }
}
