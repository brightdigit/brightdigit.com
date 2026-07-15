/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Component that represents a datetime instance
public struct Time: Component {
  /// The datetime that the element represents
  public var datetime: String?
  /// A closure that provides the contained content.
  @ComponentBuilder public var content: ContentProvider

  /// The content and behavior of this component.
  public var body: Component {
    Node.time(
      .unwrap(datetime, Node.datetime),
      .component(content())
    )
  }

  /// Initialize a time component.
  /// - parameters:
  ///   - datetime: An optional, machine-readable, datetime string to describe the time represented.
  ///   - content: A closure that provides the contained content.
  public init(
    datetime: String? = nil,
    @ComponentBuilder content: @escaping ContentProvider
  ) {
    self.datetime = datetime
    self.content = content
  }
}
