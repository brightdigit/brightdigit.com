/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Plot

/// Type representing a location's main content.
public struct Content: Hashable, ContentProtocol, Sendable {
  /// The location's title.
  public var title: String
  /// A description of the location.
  public var description: String
  /// The main body of the location's content.
  public var body: Body
  /// The location's main publishing date.
  public var date: Date
  /// The location's last modification date.
  public var lastModified: Date
  /// A path to any image that represents the location.
  public var imagePath: Path?
  /// Any audio data associated with this content.
  public var audio: Audio?
  /// Any video data associated with this content.
  public var video: Video?

  /// Initialize a new instance of this type
  /// - Parameters:
  ///   - title: The location's title.
  ///   - description: A description of the location.
  ///   - body: The main body of the location's content.
  ///   - date: The location's main publishing date.
  ///   - lastModified: The last modification date.
  ///   - imagePath: A path to any image for the location.
  ///   - audio: Any audio data associated with this content.
  ///   - video: Any video data associated with this content.
  public init(
    title: String = "",
    description: String = "",
    body: Body = Body(html: ""),
    date: Date = Date(),
    lastModified: Date = Date(),
    imagePath: Path? = nil,
    audio: Audio? = nil,
    video: Video? = nil
  ) {
    self.title = title
    self.description = description
    self.body = body
    self.date = date
    self.lastModified = lastModified
    self.imagePath = imagePath
    self.audio = audio
    self.video = video
  }
}

extension Content {
  /// Type that represents the main renderable body of a piece of content.
  public struct Body: Hashable, Sendable {
    /// The content's renderable HTML.
    public var html: String
    /// A node that can be used to embed the content in a Plot hierarchy.
    public var node: Node<HTML.BodyContext> { .raw(html) }
    /// Whether this value doesn't contain any content.
    public var isEmpty: Bool { html.isEmpty }

    /// Initialize an instance with a ready-made HTML string.
    /// - parameter html: The content HTML that the instance should cointain.
    public init(html: String) {
      self.html = html
    }

    /// Initialize an instance with a Plot `Node`.
    /// - Parameters:
    ///   - node: The node to render. See `Node` for more information.
    ///   - indentation: Any indentation to apply when rendering the node.
    public init(
      node: Node<HTML.BodyContext>,
      indentation: Indentation.Kind? = nil
    ) {
      html = node.render(indentedBy: indentation)
    }

    /// Initialize an instance using Plot's `Component` API.
    /// - Parameters:
    ///   - indentation: Any indentation to apply when rendering the components.
    ///   - components: The components that should make up this instance's content.
    public init(
      indentation: Indentation.Kind? = nil,
      @ComponentBuilder components: () -> Component
    ) {
      self.init(
        node: .component(components()),
        indentation: indentation
      )
    }
  }
}

extension Content.Body: ExpressibleByStringInterpolation {
  /// Initialize an instance using an HTML string literal.
  /// - parameter value: The content HTML that the instance should contain.
  public init(stringLiteral value: String) {
    self.init(html: value)
  }
}

extension Content.Body: Component {
  /// The component representation of this body.
  public var body: Component { node }
}
