//
//  CommandDispatcher.swift
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

import ConfigKeyKit
import Foundation

/// Top-level driver for the `brightdigitwg` commands.
///
/// Every command is now a ConfigKeyKit ``ConfigKeyKit/Command`` (the
/// swift-argument-parser tree was removed in issue #44). Commands register with
/// ``ConfigKeyKit/CommandRegistry`` and are dispatched here by name.
///
/// Some commands use multi-token names (e.g. `import podcast`, `url podcast`), so
/// dispatch greedily matches the LONGEST registered name from the leading
/// non-option tokens: it first tries the joined first two tokens, then the first
/// token alone. Anything that doesn't name a registered command prints top-level
/// help (there is no implicit default command).
public enum CommandDispatcher {
  /// The maximum number of whitespace-joined tokens that can form a command name.
  private static let maxCommandTokens = 2

  /// Registers every command, then dispatches the invocation to the matching
  /// ConfigKeyKit command — or prints top-level help when nothing matches.
  public static func run() async {
    let registry = CommandRegistry.shared
    await registry.register(PublishCommand.self)
    await registry.register(EpisodeURLCommand.self)
    await registry.register(Import.PodcastCommand.self)
    await registry.register(Import.MailchimpCommand.self)
    await registry.register(Import.WordPressCommand.self)

    // argv after the executable name.
    let rawArguments = Array(CommandLine.arguments.dropFirst())
    let helpRequested = rawArguments.contains { $0 == "--help" || $0 == "-h" }

    // Leading non-option tokens are candidate command-name components.
    let leadingTokens = rawArguments.prefix { !$0.hasPrefix("-") }

    guard
      let commandName = await matchedCommandName(
        from: Array(leadingTokens), in: registry
      )
    else {
      await printHelp(forUnmatchedLeadingTokens: Array(leadingTokens), in: registry)
      return
    }

    if helpRequested {
      if let metadata = await registry.metadata(for: commandName) {
        print(metadata.helpText)
      }
      return
    }

    do {
      let command = try await registry.createCommand(named: commandName)
      try await command.execute()
    } catch {
      FileHandle.standardError.write(Data("Error: \(error)\n".utf8))
      exit(1)
    }
  }

  /// Greedily resolves the longest registered command name from the leading
  /// tokens, checking the 2-token join before the single leading token.
  private static func matchedCommandName(
    from tokens: [String],
    in registry: CommandRegistry
  ) async -> String? {
    let maxTokens = min(maxCommandTokens, tokens.count)
    for count in stride(from: maxTokens, through: 1, by: -1) {
      let candidate = tokens.prefix(count).joined(separator: " ")
      if await registry.isRegistered(candidate) {
        return candidate
      }
    }
    return nil
  }

  /// Prints help when no full command matched.
  ///
  /// Shows namespace help if the leading token names a command namespace
  /// (`import`, `url`); otherwise prints the full top-level help.
  private static func printHelp(
    forUnmatchedLeadingTokens tokens: [String],
    in registry: CommandRegistry
  ) async {
    let available = await registry.availableCommands
    if let name = tokens.first {
      let subcommands = available.filter { $0.hasPrefix(name + " ") }
      if !subcommands.isEmpty {
        printNamespaceHelp(namespace: name, subcommands: subcommands)
        return
      }
    }
    printTopLevelHelp(availableCommands: available)
  }

  /// Prints a hand-written top-level usage listing every registered command.
  private static func printTopLevelHelp(availableCommands: [String]) {
    var lines = [
      "OVERVIEW: Command for maintaining the BrightDigit site.",
      "",
      "USAGE: brightdigitwg <command> [options]",
      "",
      "COMMANDS:",
    ]
    for command in availableCommands {
      lines.append("  \(command)")
    }
    lines.append("")
    lines.append("Run 'brightdigitwg <command> --help' for command-specific options.")
    print(lines.joined(separator: "\n"))
  }

  /// Prints usage for a command namespace, listing its subcommands.
  ///
  /// Used when a leading token names a namespace (`import`) but no full command,
  /// e.g. `brightdigitwg import`.
  private static func printNamespaceHelp(
    namespace: String,
    subcommands: [String]
  ) {
    var lines = [
      "USAGE: brightdigitwg \(namespace) <subcommand> [options]",
      "",
      "SUBCOMMANDS:",
    ]
    for subcommand in subcommands {
      lines.append("  \(subcommand)")
    }
    lines.append("")
    lines.append(
      "Run 'brightdigitwg <subcommand> --help' for subcommand-specific options."
    )
    print(lines.joined(separator: "\n"))
  }
}
