/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

extension MarkdownMetadataDecoder {
  internal struct UnkeyedContainer: UnkeyedDecodingContainer {
    internal var count: Int? { components.count }
    internal var isAtEnd: Bool { currentIndex == components.endIndex }

    internal let components: [Substring]
    internal let codingPath: [CodingKey]
    internal var currentIndex = 0

    internal mutating func decodeNil() throws -> Bool {
      false
    }

    internal mutating func decode(_ type: Bool.Type) throws -> Bool {
      try decodeNext(using: Bool.init)
    }

    internal mutating func decode(_ type: String.Type) throws -> String {
      try decodeNext()
    }

    internal mutating func decode(_ type: Double.Type) throws -> Double {
      try decodeNext(using: Double.init)
    }

    internal mutating func decode(_ type: Float.Type) throws -> Float {
      try decodeNext(using: Float.init)
    }

    internal mutating func decode(_ type: Int.Type) throws -> Int {
      try decodeNext(using: Int.init)
    }

    internal mutating func decode(_ type: Int8.Type) throws -> Int8 {
      try decodeNext(using: Int8.init)
    }

    internal mutating func decode(_ type: Int16.Type) throws -> Int16 {
      try decodeNext(using: Int16.init)
    }

    internal mutating func decode(_ type: Int32.Type) throws -> Int32 {
      try decodeNext(using: Int32.init)
    }

    internal mutating func decode(_ type: Int64.Type) throws -> Int64 {
      try decodeNext(using: Int64.init)
    }

    internal mutating func decode(_ type: UInt.Type) throws -> UInt {
      try decodeNext(using: UInt.init)
    }

    internal mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
      try decodeNext(using: UInt8.init)
    }

    internal mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
      try decodeNext(using: UInt16.init)
    }

    internal mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
      try decodeNext(using: UInt32.init)
    }

    internal mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
      try decodeNext(using: UInt64.init)
    }

    internal mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
      if T.self == URL.self {
        // The `T.self == URL.self` check guarantees the value's dynamic type
        // matches `T`, so this cast always succeeds.
        // swift-format-ignore: NeverForceUnwrap
        // swiftlint:disable:next force_cast
        return try decodeNextAsURL() as! T
      }

      return try T(
        from: SingleValueDecoder(
          value: decodeNext(),
          codingPath: codingPath
        )
      )
    }

    internal mutating func nestedContainer<T: CodingKey>(
      keyedBy type: T.Type
    ) throws -> KeyedDecodingContainer<T> {
      throw DecodingError.valueNotFound(
        KeyedDecodingContainer<T>.self,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: """
            Cannot obtain a keyed container while decoding\
            using an unkeyed metadata container.
            """
        )
      )
    }

    internal mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
      let components = try decodeNext().split(separator: ",")

      return UnkeyedContainer(
        components: components,
        codingPath: codingPath
      )
    }

    internal mutating func superDecoder() throws -> Decoder {
      UnkeyedDecoder(
        components: components,
        codingPath: codingPath
      )
    }

    private mutating func decodeNext() throws -> String {
      guard !isAtEnd else {
        throw DecodingError.valueNotFound(
          String.self,
          DecodingError.Context(
            codingPath: codingPath,
            debugDescription: """
              Index \(currentIndex) is out of bounds.
              """
          )
        )
      }

      let next = components[currentIndex]
      currentIndex += 1
      return next.trimmingCharacters(in: .whitespaces)
    }

    private mutating func decodeNextAsURL() throws -> URL {
      try URL.decode(from: decodeNext(), forKey: nil, at: codingPath)
    }

    private mutating func decodeNext<T>(using transform: (String) -> T?) throws -> T {
      let string = try decodeNext()

      guard let transformed = transform(string) else {
        throw DecodingError.dataCorruptedError(
          in: self,
          debugDescription: """
            Could not convert '\(string)' into a value\
            of type '\(String(describing: T.self))'.
            """
        )
      }

      return transformed
    }
  }

  internal struct UnkeyedDecoder: Decoder {
    internal var userInfo: [CodingUserInfoKey: Any] { [:] }

    internal let components: [Substring]
    internal var codingPath: [CodingKey]

    internal func container<T: CodingKey>(
      keyedBy type: T.Type
    ) throws -> KeyedDecodingContainer<T> {
      throw DecodingError.keyedContainerNotAvailable(
        at: codingPath,
        keyType: T.self
      )
    }

    internal func unkeyedContainer() throws -> UnkeyedDecodingContainer {
      UnkeyedContainer(components: components, codingPath: codingPath)
    }

    internal func singleValueContainer() throws -> SingleValueDecodingContainer {
      throw DecodingError.singleValueContainerNotAvailable(at: codingPath)
    }
  }
}
