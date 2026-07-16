/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct ContentError: Error {
  internal var path: Path
  internal var reason: Reason
}

extension ContentError {
  internal enum Reason {
    case itemNotFound
    case itemMutationFailed(Error)
    case pageNotFound
    case pageMutationFailed(Error)
    case markdownMetadataDecodingFailed(
      context: DecodingError.Context?,
      valueFound: Bool
    )
  }
}

extension ContentError: PublishingErrorConvertible {
  internal func publishingError(forStepNamed stepName: String?) -> PublishingError {
    PublishingError(
      stepName: stepName,
      path: path,
      infoMessage: infoMessage,
      underlyingError: underlyingError
    )
  }
}

extension ContentError {
  fileprivate var infoMessage: String {
    switch reason {
    case .itemNotFound:
      return "No item found at '\(path)'."
    case .itemMutationFailed:
      return "Item mutation failed"
    case .pageNotFound:
      return "Page not found"
    case .pageMutationFailed:
      return "Page mutation failed"
    case .markdownMetadataDecodingFailed(let context, let valueFound):
      let key = context?.codingPath.map({ $0.stringValue }).joined(separator: ".")
      let keyString = key.map { "key '\($0)'" } ?? "unknown key"
      let adjective = valueFound ? "Invalid" : "Missing"
      return "\(adjective) metadata value for \(keyString)"
    }
  }

  fileprivate var underlyingError: Error? {
    switch reason {
    case .itemNotFound, .pageNotFound, .markdownMetadataDecodingFailed:
      return nil
    case .itemMutationFailed(let error), .pageMutationFailed(let error):
      return error
    }
  }
}
