/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Component used to render an `<img>` element for displaying an image.
public struct Image: Component {
  /// The URL of the image to render.
  public var url: URLRepresentable
  /// An alternative text that describes the image in case it couldn't be
  /// loaded, or if the user is using a screen reader.
  public var description: String

  /// The content and behavior of this component.
  public var body: Component {
    Node<HTML.BodyContext>.img(.src(url), .alt(description))
  }

  /// Create a new image instance.
  /// - parameters:
  ///   - url: The URL of the image to render.
  ///   - description: An alternative text that describes the image in case
  ///     it couldn't be loaded, or if the user is using a screen reader.
  public init(
    url: URLRepresentable,
    description: String
  ) {
    self.url = url
    self.description = description
  }

  /// Create a new decorative image that doesn't have a description.
  /// - parameter url: The URL of the image to render.
  public init(_ url: URLRepresentable) {
    self.init(url: url, description: "")
  }
}
