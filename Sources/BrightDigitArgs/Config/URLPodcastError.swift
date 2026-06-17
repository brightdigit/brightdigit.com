/// Errors surfaced while resolving and running `url podcast` via the
/// swift-configuration stack (issue #44).
public enum URLPodcastError: Error, CustomStringConvertible {
  case missingRequiredOption(String)
  case invalidBaseURL(String)

  public var description: String {
    switch self {
    case let .missingRequiredOption(name):
      return "Missing required option: \(name)"
    case let .invalidBaseURL(value):
      return "Invalid base URL: \(value)"
    }
  }
}
