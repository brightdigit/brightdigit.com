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
    let stringValue: String
    let intValue: Int?

    init(_ string: String) {
        self.stringValue = string
        self.intValue = nil
    }

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

internal extension Decoder {
    func decode<T: Decodable>(_ key: String, as type: T.Type = T.self) throws -> T {
        let container = try self.container(keyedBy: StringCodingKey.self)
        return try container.decode(type, forKey: StringCodingKey(key))
    }

    func decodeIfPresent<T: Decodable>(_ key: String, as type: T.Type = T.self) throws -> T? {
        let container = try self.container(keyedBy: StringCodingKey.self)
        return try container.decodeIfPresent(type, forKey: StringCodingKey(key))
    }

    func decodeSingleValue<T: Decodable>(as type: T.Type = T.self) throws -> T {
        let container = try singleValueContainer()
        return try container.decode(type)
    }
}

internal extension Encoder {
    func encodeSingleValue<T: Encodable>(_ value: T) throws {
        var container = singleValueContainer()
        try container.encode(value)
    }
}

internal extension Data {
    func decoded<T: Decodable>(as type: T.Type = T.self) throws -> T {
        try JSONDecoder().decode(type, from: self)
    }
}

internal extension Encodable {
    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
