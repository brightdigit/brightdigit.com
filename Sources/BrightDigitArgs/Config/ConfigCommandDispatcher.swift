import ConfigKeyKit
import Foundation

/// Routes argv to the migrated swift-configuration commands when they match,
/// otherwise signals the caller to fall back to the legacy ArgumentParser tree.
///
/// During the incremental issue #44 migration only some subcommands are backed
/// by ConfigKeyKit + swift-configuration. Each migrated command is matched by
/// its own ``ConfigKeyKit/Command/commandName`` (which may be multi-word, e.g.
/// `url podcast`) and run through ConfigKeyKit's `Command` API, so adding the
/// next migrated command is just a matter of listing its type.
public enum ConfigCommandDispatcher {
  /// Commands already migrated to ConfigKeyKit + swift-configuration.
  private static let migratedCommands: [any Command.Type] = [
    URLPodcastCommand.self
  ]

  /// Attempts to handle the given arguments with a migrated command.
  ///
  /// - Returns: `true` if a migrated command handled the invocation (including
  ///   help or errors); `false` if the caller should fall back to ArgumentParser.
  public static func tryRun(
    arguments: [String] = CommandLine.arguments
  ) async -> Bool {
    let tokens = Array(arguments.dropFirst())
    guard let command = migratedCommands.first(where: { matches($0, tokens) }) else {
      return false
    }
    await run(command, tokens: tokens)
    return true
  }

  /// Whether `tokens` begin with the command's (possibly multi-word) name.
  private static func matches(_ command: any Command.Type, _ tokens: [String]) -> Bool {
    let name = command.commandName.split(separator: " ").map(String.init)
    return tokens.count >= name.count && Array(tokens.prefix(name.count)) == name
  }

  private static func run(_ command: any Command.Type, tokens: [String]) async {
    if tokens.contains(where: { $0 == "--help" || $0 == "-h" || $0 == "help" }) {
      command.printHelp()
      return
    }
    do {
      // The reader reads CommandLine.arguments directly, so the flags after the
      // command name are parsed as-is.
      let instance = try await command.createInstance()
      try await instance.execute()
    } catch {
      FileHandle.standardError.write(Data("Error: \(error)\n".utf8))
      exit(1)
    }
  }
}
