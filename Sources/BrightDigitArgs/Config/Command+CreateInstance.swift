import ConfigKeyKit
import Configuration

extension Command
where Config.ConfigReader == Configuration.ConfigReader, Config.BaseConfig == Never {
  /// Default ``ConfigKeyKit/Command/createInstance()`` for commands whose
  /// ``Config`` resolves from a CLI-first, then-environment
  /// ``Configuration/ConfigReader``.
  ///
  /// Every migrated command (issue #44) builds the same two-provider reader and
  /// parses its `Config` from it; this default removes that per-command
  /// boilerplate.
  public static func createInstance() async throws -> Self {
    let reader = Configuration.ConfigReader(providers: [
      CommandLineArgumentsProvider(),
      EnvironmentVariablesProvider(),
    ])
    let config = try await Config(configuration: reader)
    return Self(config: config)
  }
}
