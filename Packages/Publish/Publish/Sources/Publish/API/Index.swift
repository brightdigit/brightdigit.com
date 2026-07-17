/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// A representation of a website's main index page
public struct Index: Location, Sendable {
  /// The index page's path, which is always the website's root.
  public var path: Path { "" }
  /// The index page's main content.
  public var content = Content()
}
