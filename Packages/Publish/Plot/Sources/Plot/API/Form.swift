/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Component used to render a `<form>` element for user-submittable data.
public struct Form: Component {
  /// The URL that the form's data should be submitted to.
  public var url: URLRepresentable
  /// The HTTP request method that should be used when submitting the form.
  public var method: HTMLFormMethod?
  /// The way that the form's data should be encoded when submitted.
  public var contentType: HTMLFormContentType?
  /// Whether the browser should validate the form before submission.
  public var enableValidation: Bool
  /// A closure that provides the form's child components.
  @ComponentBuilder public var content: ContentProvider

  /// The content and behavior of this component.
  public var body: Component {
    Node.form(
      .action(url),
      .unwrap(method, Node.method),
      .unwrap(contentType, Node.enctype),
      .novalidate(!enableValidation),
      .component(content())
    )
  }

  /// Create a new form instance.
  /// - parameters:
  ///   - url: The URL that the form's data should be submitted to.
  ///   - method: The HTTP request method that should be used when submitting the form.
  ///   - contentType: The way that the form's data should be encoded when submitted.
  ///   - enableValidation: Whether the browser should validate the form before submission.
  ///   - content: A closure that provides the form's child components.
  public init(
    url: URLRepresentable,
    method: HTMLFormMethod? = nil,
    contentType: HTMLFormContentType? = nil,
    enableValidation: Bool = true,
    @ComponentBuilder content: @escaping ContentProvider
  ) {
    self.url = url
    self.method = method
    self.contentType = contentType
    self.enableValidation = enableValidation
    self.content = content
  }
}
