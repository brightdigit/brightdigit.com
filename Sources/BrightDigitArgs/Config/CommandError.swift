/// Errors surfaced while resolving and running `brightdigitwg` commands via the
/// swift-configuration stack (issue #44).
///
/// Shared across the migrated ConfigKeyKit commands (`publish`, `import podcast`,
/// `import mailchimp`, `import wordpress`). Each command resolves its options
/// through a ``Configuration/ConfigReader`` and throws one of these cases when a
/// required option is missing or a supplied value cannot be parsed.
public enum CommandError: Error, CustomStringConvertible {
  /// A required option was not supplied via CLI or environment.
  case missingRequiredOption(String)
  /// A supplied option value could not be parsed into the expected type.
  case invalidValue(option: String, value: String)
  /// A supplied value was expected to be a URL but could not be parsed.
  case invalidURL(String)

  public var description: String {
    switch self {
    case let .missingRequiredOption(name):
      return "Missing required option: \(name)"
    case let .invalidValue(option, value):
      return "Invalid value for \(option): \(value)"
    case let .invalidURL(value):
      return "Invalid URL: \(value)"
    }
  }
}
