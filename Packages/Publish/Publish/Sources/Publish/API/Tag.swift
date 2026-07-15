/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// Type used to represent a content tag. Items may be tagged, and then
/// retrieved based on any tag that they were associated with.
public struct Tag: StringWrapper {
  /// The underlying string value of the tag.
  public var string: String

  /// Initialize a tag with an underlying string value.
  /// - parameter string: The string to form the tag from.
  public init(_ string: String) {
    self.string = string
  }
}

extension Tag {
  /// Return a normalized string representation of this tag, which can
  /// be used to form URLs or identifiers.
  public func normalizedString() -> String {
    string.normalized()
  }
}
