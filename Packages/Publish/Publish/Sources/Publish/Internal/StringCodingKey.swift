/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

// A tiny internal replacement for the handful of Codextended conveniences that
// Publish relied on — decoding/encoding values keyed by plain string literals
// (used throughout Markdown front-matter decoding) and the `Data`/`Encodable`
// round-trips used by the RSS/podcast feed caches. Behavior is identical to the
// previous Codextended usage: the same string keys, and `JSONEncoder`/
// `JSONDecoder` with default settings.

/// A `CodingKey` created from a plain string.
internal struct StringCodingKey: CodingKey {
  internal let stringValue: String
  internal let intValue: Int?

  internal init(_ string: String) {
    self.stringValue = string
    self.intValue = nil
  }

  internal init(stringValue: String) {
    self.stringValue = stringValue
    self.intValue = nil
  }

  internal init?(intValue: Int) {
    self.stringValue = String(intValue)
    self.intValue = intValue
  }
}

extension Decoder {
  internal func decode<T: Decodable>(_ key: String, as type: T.Type = T.self) throws -> T {
    let container = try self.container(keyedBy: StringCodingKey.self)
    return try container.decode(type, forKey: StringCodingKey(key))
  }

  internal func decodeIfPresent<T: Decodable>(
    _ key: String,
    as type: T.Type = T.self
  ) throws -> T? {
    let container = try self.container(keyedBy: StringCodingKey.self)
    return try container.decodeIfPresent(type, forKey: StringCodingKey(key))
  }

  internal func decodeSingleValue<T: Decodable>(as type: T.Type = T.self) throws -> T {
    let container = try singleValueContainer()
    return try container.decode(type)
  }
}

extension Encoder {
  internal func encodeSingleValue<T: Encodable>(_ value: T) throws {
    var container = singleValueContainer()
    try container.encode(value)
  }
}

extension Data {
  internal func decoded<T: Decodable>(as type: T.Type = T.self) throws -> T {
    try JSONDecoder().decode(type, from: self)
  }
}

extension Encodable {
  internal func encoded() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
