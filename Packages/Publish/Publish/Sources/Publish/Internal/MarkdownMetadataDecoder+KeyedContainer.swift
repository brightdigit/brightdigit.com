/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

extension MarkdownMetadataDecoder {
  internal struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    internal var allKeys: [Key] { keys.all() }

    internal let metadata: [String: String]
    internal let keys: KeyMap<Key>
    internal let codingPath: [CodingKey]
    internal let prefix: String
    internal let dateParseStrategy: Date.ParseStrategy

    internal init(
      metadata: [String: String],
      codingPath: [CodingKey],
      dateParseStrategy: Date.ParseStrategy
    ) {
      self.metadata = metadata
      self.keys = KeyMap(raw: metadata.keys, codingPath: codingPath)
      self.codingPath = codingPath
      self.prefix = codingPath.asPrefix()
      self.dateParseStrategy = dateParseStrategy
    }

    internal func contains(_ key: Key) -> Bool {
      keys.contains(key)
    }

    internal func decodeNil(forKey key: Key) throws -> Bool {
      false
    }

    internal func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      try decode(key, transform: Bool.init)
    }

    internal func decode(_ type: String.Type, forKey key: Key) throws -> String {
      try decode(key)
    }

    internal func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      try decode(key, transform: Double.init)
    }

    internal func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      try decode(key, transform: Float.init)
    }

    internal func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      try decode(key, transform: Int.init)
    }

    internal func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
      try decode(key, transform: Int8.init)
    }

    internal func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
      try decode(key, transform: Int16.init)
    }

    internal func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
      try decode(key, transform: Int32.init)
    }

    internal func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
      try decode(key, transform: Int64.init)
    }

    internal func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      try decode(key, transform: UInt.init)
    }

    internal func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
      try decode(key, transform: UInt8.init)
    }

    internal func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
      try decode(key, transform: UInt16.init)
    }

    internal func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
      try decode(key, transform: UInt32.init)
    }

    internal func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
      try decode(key, transform: UInt64.init)
    }

    internal func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
      // The surrounding `T.self == …` checks guarantee the decoded value's
      // dynamic type matches `T`, so these casts always succeed.
      if T.self == URL.self {
        // swift-format-ignore: NeverForceUnwrap
        // swiftlint:disable:next force_cast
        return try decodeURL(forKey: key) as! T
      } else if T.self == Date.self {
        // swift-format-ignore: NeverForceUnwrap
        // swiftlint:disable:next force_cast
        return try decodeDate(forKey: key) as! T
      }

      return try T(
        from: MarkdownMetadataDecoder(
          metadata: metadata,
          codingPath: codingPath.appending(key),
          dateParseStrategy: dateParseStrategy
        )
      )
    }

    internal func nestedContainer<T: CodingKey>(
      keyedBy type: T.Type,
      forKey key: Key
    ) throws -> KeyedDecodingContainer<T> {
      KeyedDecodingContainer(
        KeyedContainer<T>(
          metadata: metadata,
          codingPath: codingPath.appending(key),
          dateParseStrategy: dateParseStrategy
        )
      )
    }

    internal func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
      let string = try decode(key)

      return UnkeyedContainer(
        components: string.split(separator: ","),
        codingPath: codingPath.appending(key)
      )
    }

    internal func superDecoder() throws -> Decoder {
      MarkdownMetadataDecoder(
        metadata: metadata,
        codingPath: codingPath,
        dateParseStrategy: dateParseStrategy
      )
    }

    internal func superDecoder(forKey key: Key) throws -> Decoder {
      MarkdownMetadataDecoder(
        metadata: metadata,
        codingPath: codingPath.appending(key),
        dateParseStrategy: dateParseStrategy
      )
    }

    private func decode(_ key: Key) throws -> String {
      guard let string = metadata[prefix + key.stringValue] else {
        throw DecodingError.keyNotFound(
          key,
          DecodingError.Context(
            codingPath: codingPath.appending(key),
            debugDescription: """
              No value found for key '\(key.stringValue)'.
              """
          )
        )
      }

      return string
    }

    private func decode<T>(_ key: Key, transform: (String) -> T?) throws -> T {
      let string = try decode(key)

      guard let transformed = transform(string) else {
        throw DecodingError.dataCorruptedError(
          forKey: key,
          in: self,
          debugDescription: """
            Could not convert '\(string)' into a value\
            of type '\(String(describing: T.self))'.
            """
        )
      }

      return transformed
    }

    private func decodeURL(forKey key: Key) throws -> URL {
      try URL.decode(from: decode(key), forKey: key, at: codingPath)
    }

    private func decodeDate(forKey key: Key) throws -> Date {
      try Date.decode(
        from: decode(key),
        forKey: key,
        at: codingPath,
        strategy: dateParseStrategy
      )
    }
  }
}
