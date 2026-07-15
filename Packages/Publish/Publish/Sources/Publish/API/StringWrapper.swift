/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Protocol adopted by types that act as type-safe wrappers around strings.
public protocol StringWrapper: CustomStringConvertible,
  ExpressibleByStringInterpolation,
  Codable,
  Hashable,
  Comparable,
  Sendable
{
  /// The underlying string value backing this instance.
  var string: String { get }
  /// Initialize a new instance with an underlying string value.
  /// - parameter string: The string to form a new value from.
  init(_ string: String)
}

extension StringWrapper {
  /// A textual representation of the value, equal to its underlying string.
  public var description: String { string }

  /// Initialize a new value from a string literal.
  /// - parameter value: The string literal to form a value from.
  public init(stringLiteral value: String) {
    self.init(value)
  }

  /// Initialize a new value by decoding a single string value.
  /// - parameter decoder: The decoder to read the string from.
  /// - Throws: An error if decoding fails.
  public init(from decoder: Decoder) throws {
    try self.init(decoder.decodeSingleValue())
  }

  /// Compare two values based on their underlying strings.
  /// - Parameters:
  ///   - lhs: The first value to compare.
  ///   - rhs: The second value to compare.
  /// - Returns: `true` if `lhs` sorts before `rhs`.
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.string < rhs.string
  }

  /// Encode this value as a single string value.
  /// - parameter encoder: The encoder to write the string to.
  /// - Throws: An error if encoding fails.
  public func encode(to encoder: Encoder) throws {
    try encoder.encodeSingleValue(string)
  }
}
