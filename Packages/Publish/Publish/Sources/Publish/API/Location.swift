/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// Protocol adopted by types that can act as a location
/// that a user can navigate to within a web browser.
public protocol Location: ContentProtocol {
  /// The absolute path of the location within the website,
  /// excluding its base URL. For example, an item "article"
  /// contained within a section "mySection" will have the
  /// path "mySection/article". You can resolve the absolute
  /// URL for a location and/or path using your `Website`.
  var path: Path { get }
  /// The location's main content. You can also access this
  /// type's nested properties as top-level properties on the
  /// location itself, so `title`, rather than `content.title`.
  var content: Content { get set }
}

extension Location {
  /// The location's title, forwarded from its `content`.
  public var title: String {
    get { content.title }
    set { content.title = newValue }
  }

  /// The location's description, forwarded from its `content`.
  public var description: String {
    get { content.description }
    set { content.description = newValue }
  }

  /// The location's body, forwarded from its `content`.
  public var body: Content.Body {
    get { content.body }
    set { content.body = newValue }
  }

  /// The location's date, forwarded from its `content`.
  public var date: Date {
    get { content.date }
    set { content.date = newValue }
  }

  /// The location's last modification date, forwarded from its `content`.
  public var lastModified: Date {
    get { content.lastModified }
    set { content.lastModified = newValue }
  }

  /// The location's image path, forwarded from its `content`.
  public var imagePath: Path? {
    get { content.imagePath }
    set { content.imagePath = newValue }
  }

  /// The location's audio, forwarded from its `content`.
  public var audio: Audio? {
    get { content.audio }
    set { content.audio = newValue }
  }

  /// The location's video, forwarded from its `content`.
  public var video: Video? {
    get { content.video }
    set { content.video = newValue }
  }
}
