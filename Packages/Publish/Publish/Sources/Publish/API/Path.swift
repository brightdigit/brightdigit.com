/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// Type used to express a path within a website, either to a
/// location or to a resource, such as a file or image.
public struct Path: StringWrapper {
  /// The underlying string value of the path.
  public var string: String

  /// Initialize a path with an underlying string value.
  /// - parameter string: The string to form the path from.
  public init(_ string: String) {
    self.string = string
  }
}

extension Path {
  /// The default path used when generating RSS feeds.
  public static var defaultForRSSFeed: Path { "feed.rss" }
  /// The default path used when generating HTML for tags and tag lists.
  public static var defaultForTagHTML: Path { "tags" }
  /// The default path used for website favicon.
  public static var defaultForFavicon: Path { "images/favicon.png" }

  /// Convert this path into an absolute string, which can be used to
  /// refer to locations and resources based on the root of a website.
  public var absoluteString: String {
    guard string.first != "/" else {
      return string
    }
    guard !string.hasPrefix("http://") else {
      return string
    }
    guard !string.hasPrefix("https://") else {
      return string
    }
    return "/" + string
  }

  /// Append a component to this path, such as a folder or file name.
  /// - parameter component: The component to add.
  /// - Returns: A new path with the component appended.
  public func appendingComponent(_ component: String) -> Path {
    guard !string.isEmpty else {
      return Path(component)
    }

    let component = component.drop(while: { $0 == "/" })
    let separator = (string.last == "/" ? "" : "/")
    return "\(string)\(separator)\(component)"
  }
}
