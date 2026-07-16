/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

extension MarkdownMetadataDecoder {
  internal struct SingleValueContainer: SingleValueDecodingContainer {
    internal let value: String
    internal let codingPath: [CodingKey]

    internal func decodeNil() -> Bool {
      false
    }

    internal func decode(_ type: Bool.Type) throws -> Bool {
      try decode(using: Bool.init)
    }

    internal func decode(_ type: String.Type) throws -> String {
      value
    }

    internal func decode(_ type: Double.Type) throws -> Double {
      try decode(using: Double.init)
    }

    internal func decode(_ type: Float.Type) throws -> Float {
      try decode(using: Float.init)
    }

    internal func decode(_ type: Int.Type) throws -> Int {
      try decode(using: Int.init)
    }

    internal func decode(_ type: Int8.Type) throws -> Int8 {
      try decode(using: Int8.init)
    }

    internal func decode(_ type: Int16.Type) throws -> Int16 {
      try decode(using: Int16.init)
    }

    internal func decode(_ type: Int32.Type) throws -> Int32 {
      try decode(using: Int32.init)
    }

    internal func decode(_ type: Int64.Type) throws -> Int64 {
      try decode(using: Int64.init)
    }

    internal func decode(_ type: UInt.Type) throws -> UInt {
      try decode(using: UInt.init)
    }

    internal func decode(_ type: UInt8.Type) throws -> UInt8 {
      try decode(using: UInt8.init)
    }

    internal func decode(_ type: UInt16.Type) throws -> UInt16 {
      try decode(using: UInt16.init)
    }

    internal func decode(_ type: UInt32.Type) throws -> UInt32 {
      try decode(using: UInt32.init)
    }

    internal func decode(_ type: UInt64.Type) throws -> UInt64 {
      try decode(using: UInt64.init)
    }

    internal func decode<T: Decodable>(_ type: T.Type) throws -> T {
      let decoder = SingleValueDecoder(
        value: value,
        codingPath: codingPath
      )

      return try T(from: decoder)
    }

    private func decode<T>(using transform: (String) -> T?) throws -> T {
      guard let transformed = transform(value) else {
        throw DecodingError.dataCorruptedError(
          in: self,
          debugDescription: """
            Could not convert '\(value)' into a value\
            of type '\(String(describing: T.self))'.
            """
        )
      }

      return transformed
    }
  }

  internal struct SingleValueDecoder: Decoder {
    internal var userInfo: [CodingUserInfoKey: Any] { [:] }

    internal let value: String
    internal let codingPath: [CodingKey]

    internal func container<T: CodingKey>(
      keyedBy type: T.Type
    ) throws -> KeyedDecodingContainer<T> {
      throw DecodingError.keyedContainerNotAvailable(
        at: codingPath,
        keyType: T.self
      )
    }

    internal func unkeyedContainer() throws -> UnkeyedDecodingContainer {
      throw DecodingError.unkeyedContainerNotAvailable(at: codingPath)
    }

    internal func singleValueContainer() throws -> SingleValueDecodingContainer {
      SingleValueContainer(
        value: value,
        codingPath: codingPath
      )
    }
  }

  internal final class KeyMap<Key: CodingKey> {
    private typealias Evaluated = (array: [Key], set: Set<String>)

    private let raw: Dictionary<String, String>.Keys
    private let codingPath: [CodingKey]
    private var evaluated: Evaluated?

    internal init(
      raw: Dictionary<String, String>.Keys,
      codingPath: [CodingKey]
    ) {
      self.raw = raw
      self.codingPath = codingPath
    }

    internal func all() -> [Key] {
      evaluateIfNeeded().array
    }

    internal func contains(_ key: Key) -> Bool {
      evaluateIfNeeded().set.contains(key.stringValue)
    }

    private func evaluateIfNeeded() -> Evaluated {
      if let evaluated = evaluated {
        return evaluated
      }

      var evaluated: Evaluated = ([], [])

      for rawKey in raw {
        let components = rawKey.split(separator: ".")

        for (index, component) in components.enumerated() {
          guard codingPath.count > index else {
            let stringKey = String(component)

            if let key = Key(stringValue: stringKey) {
              evaluated.array.append(key)
              evaluated.set.insert(stringKey)
            }

            break
          }
        }
      }

      self.evaluated = evaluated
      return evaluated
    }
  }
}
