/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

internal final class MarkdownMetadataDecoder: Decoder {
  internal var userInfo: [CodingUserInfoKey: Any] { [:] }
  internal let codingPath: [CodingKey]

  private let metadata: [String: String]
  private let dateParseStrategy: Date.ParseStrategy
  private lazy var keyedContainers = [ObjectIdentifier: Any]()

  internal init(
    metadata: [String: String],
    codingPath: [CodingKey] = [],
    dateParseStrategy: Date.ParseStrategy
  ) {
    self.metadata = metadata
    self.codingPath = codingPath
    self.dateParseStrategy = dateParseStrategy
  }

  internal func container<T: CodingKey>(
    keyedBy type: T.Type
  ) throws -> KeyedDecodingContainer<T> {
    let typeID = ObjectIdentifier(type)

    if let cached = keyedContainers[typeID] {
      // `keyedContainers` is keyed by the container's own type identifier,
      // so a cached value for `typeID` is always a `KeyedContainer<T>`.
      // swift-format-ignore: NeverForceUnwrap
      // swiftlint:disable:next force_cast
      return KeyedDecodingContainer(cached as! KeyedContainer<T>)
    }

    let container = KeyedContainer<T>(
      metadata: metadata,
      codingPath: codingPath,
      dateParseStrategy: dateParseStrategy
    )

    keyedContainers[typeID] = container
    return KeyedDecodingContainer(container)
  }

  internal func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    let prefix = codingPath.asPrefix(includingTrailingSeparator: false)

    guard let string = metadata[prefix] else {
      throw DecodingError.unkeyedContainerNotAvailable(at: codingPath)
    }

    return UnkeyedContainer(
      components: string.split(separator: ","),
      codingPath: codingPath
    )
  }

  internal func singleValueContainer() throws -> SingleValueDecodingContainer {
    let prefix = codingPath.asPrefix(includingTrailingSeparator: false)

    guard let string = metadata[prefix] else {
      throw DecodingError.singleValueContainerNotAvailable(at: codingPath)
    }

    return SingleValueContainer(value: string, codingPath: codingPath)
  }
}

extension Array where Element == CodingKey {
  internal func asPrefix(includingTrailingSeparator addTrailingSeparator: Bool = true) -> String {
    var isFirstKey = true

    let string = reduce(into: "") { string, key in
      if isFirstKey {
        isFirstKey = false
      } else {
        string.append(".")
      }

      string.append(key.stringValue)
    }

    guard !string.isEmpty, addTrailingSeparator else {
      return string
    }

    return string.appending(".")
  }
}

extension URL {
  internal static func decode(
    from string: String,
    forKey key: CodingKey?,
    at codingPath: [CodingKey]
  ) throws -> Self {
    guard let url = URL(string: string) else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: key.map(codingPath.appending) ?? codingPath,
          debugDescription: "Invalid URL string."
        )
      )
    }

    return url
  }
}

extension Date {
  internal static func decode(
    from string: String,
    forKey key: CodingKey?,
    at codingPath: [CodingKey],
    strategy: Date.ParseStrategy
  ) throws -> Self {
    guard let date = try? strategy.parse(string) else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: key.map(codingPath.appending) ?? codingPath,
          debugDescription: """
            Invalid date string. Expected format: yyyy-MM-dd HH:mm.
            """
        )
      )
    }

    return date
  }
}

extension DecodingError {
  internal static func keyedContainerNotAvailable<T: CodingKey>(
    at path: [CodingKey],
    keyType: T.Type
  ) -> Self {
    .valueNotFound(
      KeyedDecodingContainer<T>.self,
      DecodingError.Context(
        codingPath: path,
        debugDescription: """
          Cannot obtain a keyed decoding container within this context.
          """
      )
    )
  }

  internal static func unkeyedContainerNotAvailable(at path: [CodingKey]) -> Self {
    .valueNotFound(
      UnkeyedDecodingContainer.self,
      DecodingError.Context(
        codingPath: path,
        debugDescription: """
          Cannot obtain an unkeyed decoding container within this context.
          """
      )
    )
  }

  internal static func singleValueContainerNotAvailable(at path: [CodingKey]) -> Self {
    .valueNotFound(
      SingleValueDecodingContainer.self,
      DecodingError.Context(
        codingPath: path,
        debugDescription: """
          Cannot obtain a single value decoding container within this context.
          """
      )
    )
  }
}
