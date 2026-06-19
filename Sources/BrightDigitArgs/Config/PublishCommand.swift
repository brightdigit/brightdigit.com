//
//  PublishCommand.swift
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

  public func execute() async throws {
    try await BrightDigitSite().publish(includeDrafts: config.mode == .drafts)
  }
}
