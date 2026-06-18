import ConfigKeyKit
import Configuration

/// Bridges swift-configuration's `ConfigReader` to ConfigKeyKit's
/// ``ConfigKeyKit/ConfigValueReading``.
///
/// ConfigKeyKit's core supplies the CLI → ENV → default `read(_:)` resolution
/// (issue #1); this is the only glue the consumer needs — the `string`/`int`/
/// `double` requirements are witnessed by `ConfigReader`'s own methods and the
/// associated `Key` infers to `Configuration.ConfigKey`.
extension ConfigReader: @retroactive ConfigValueReading {
  public func makeConfigKey(_ string: String) -> Configuration.ConfigKey {
    Configuration.ConfigKey(string)
  }
}
