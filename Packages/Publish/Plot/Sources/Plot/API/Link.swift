/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Component used to render a link/anchor using an `<a>` element.
public struct Link: Component {
  /// The URL that the link should point to.
  public var url: URLRepresentable
  /// A closure that provides the components that should make up the link's label.
  @ComponentBuilder public var label: ContentProvider

  @EnvironmentValue(.linkRelationship) private var relationship
  @EnvironmentValue(.linkTarget) private var target

  /// The content and behavior of this component.
  public var body: Component {
    Node.a(
      .href(url),
      .unwrap(relationship, Node.rel),
      .unwrap(target, Node.target),
      .component(label())
    )
  }

  /// Create a new link instance.
  /// - parameters:
  ///   - url: The URL that the link should point to.
  ///   - label: A closure that provides the components that should make up
  ///     the link's label.
  public init(
    url: URLRepresentable,
    @ComponentBuilder label: @escaping ContentProvider
  ) {
    self.url = url
    self.label = label
  }

  /// Create a new link instance.
  /// - parameters:
  ///   - label: The link's text-based label.
  ///   - url: The URL that the link should point to.
  public init(_ label: String, url: URLRepresentable) {
    self.init(url: url) {
      Node<HTML.BodyContext>.text(label)
    }
  }
}
