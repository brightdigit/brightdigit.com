import ArgumentParser
import ConfigKeyKit
import Foundation

/// Top-level driver for the migrated `brightdigitwg` commands.
///
/// Mirrors ConfigKeyKit's command-dispatch pattern (see MistKit's
/// `MistDemoRunner`): migrated commands register with ``ConfigKeyKit/CommandRegistry``
/// and are dispatched by name via ``ConfigKeyKit/CommandLineParser``. During the
/// incremental issue #44 migration, any argument that doesn't name a registered
/// command falls through to the legacy ArgumentParser tree
/// (`BrightDigitSiteCommand.main()`).
public enum BrightDigitWGRunner {
  /// Registers migrated commands, then dispatches the invocation — either to a
  /// matching ConfigKeyKit command or to the legacy ArgumentParser tree.
  public static func run() async {
    let registry = CommandRegistry.shared
    await registry.register(EpisodeURLCommand.self)

    let parser = CommandLineParser()
    guard let commandName = parser.parseCommandName(),
      await registry.isRegistered(commandName)
    else {
      // Not a migrated command — hand off to the legacy ArgumentParser tree.
      await BrightDigitSiteCommand.main()
      return
    }

    if parser.isHelpRequested() {
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
}
