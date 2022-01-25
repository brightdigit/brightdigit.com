import Foundation
import Publish

enum PiError: Error, LocalizedError {
  case missingContentFor(Location)
  case missingField(MissingField, Item<BrightDigitSite>)
  case invalidURLValue(String)

  var errorDescription: String? {
    switch self {
    case let .missingContentFor(location):
      return "Missing content for location: \(location)"
    case let .missingField(field, item):
      return "Missing field \(field) from \(item.path)"
    case let .invalidURLValue(string):
      return "Invalid URL Value: \(string)"
    }
  }
}
