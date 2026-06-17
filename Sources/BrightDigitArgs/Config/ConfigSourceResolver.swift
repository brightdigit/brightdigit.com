import ConfigKeyKit
import Configuration
import Foundation

/// Resolves a ``ConfigKeyKit/ConfigurationKey`` across command-line arguments
/// (highest precedence) then environment variables, using a dedicated
/// ``Configuration/ConfigReader`` per source so each provider receives the
/// source-appropriate key string that ConfigKeyKit produces.
///
/// ConfigKeyKit deliberately exposes distinct CLI / env key strings (the CLI
/// flag and the `BRIGHTDIGIT_`-prefixed env var are not the same token), which
/// is why a single shared `ConfigReader` cannot serve both: swift-configuration
/// re-derives a name from one key for every provider. Reading each source with
/// its own single-provider reader keyed by the exact ConfigKeyKit string keeps
/// the two namespaces independent.
public struct ConfigSourceResolver: Sendable {
  private let cli: ConfigReader
  private let env: ConfigReader

  public init(
    arguments: [String] = CommandLine.arguments,
    environment: [String: String] = ProcessInfo.processInfo.environment
  ) {
    self.cli = ConfigReader(
      provider: CommandLineArgumentsProvider(arguments: arguments)
    )
    self.env = ConfigReader(
      provider: EnvironmentVariablesProvider(environmentVariables: environment)
    )
  }

  public func string(for key: any ConfigurationKey) -> String? {
    if let cliKey = key.key(for: .commandLine),
      let value = cli.string(forKey: Configuration.ConfigKey(cliKey))
    {
      return value
    }
    if let envKey = key.key(for: .environment),
      let value = env.string(forKey: Configuration.ConfigKey(envKey))
    {
      return value
    }
    return nil
  }

  public func int(for key: any ConfigurationKey) -> Int? {
    if let cliKey = key.key(for: .commandLine),
      let value = cli.int(forKey: Configuration.ConfigKey(cliKey))
    {
      return value
    }
    if let envKey = key.key(for: .environment),
      let value = env.int(forKey: Configuration.ConfigKey(envKey))
    {
      return value
    }
    return nil
  }
}
