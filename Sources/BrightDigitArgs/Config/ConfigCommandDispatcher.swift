import ConfigKeyKit
import Foundation

/// Routes argv to the migrated swift-configuration commands when they match,
/// otherwise signals the caller to fall back to the legacy ArgumentParser tree.
///
/// During the incremental issue #44 migration only some subcommands are backed
/// by ConfigKeyKit + swift-configuration. This dispatcher recognises those, runs
/// them, and reports whether it handled the invocation so the entry point can
/// delegate everything else to `BrightDigitSiteCommand.main()`.
public enum ConfigCommandDispatcher {
  /// Attempts to handle the given arguments with a migrated command.
  ///
  /// - Returns: `true` if a migrated command handled the invocation (including
  ///   help or errors); `false` if the caller should fall back to ArgumentParser.
  public static func tryRun(
    arguments: [String] = CommandLine.arguments
  ) async -> Bool {
    // Currently migrated: `url podcast`.
    guard arguments.count >= 3,
      arguments[1] == "url",
      arguments[2] == "podcast"
    else {
      return false
    }

    let remaining = Array(arguments.dropFirst(3))
    let parser = CommandLineParser(arguments: ["brightdigitwg"] + remaining)
    if parser.isHelpRequested() {
      BrightDigitSiteCommand.URLPodcastCommand.printHelp()
      return true
    }

    do {
      // CommandLineArgumentsProvider reads CommandLine.arguments directly, so the
      // flags after `url podcast` are parsed as-is.
      let command = try await BrightDigitSiteCommand.URLPodcastCommand.createInstance()
      try await command.execute()
    } catch {
      FileHandle.standardError.write(Data("Error: \(error)\n".utf8))
      exit(1)
    }
    return true
  }
}
