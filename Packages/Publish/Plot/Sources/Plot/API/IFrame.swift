/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Component used to render an `<iframe>` element for an embedded page.
public struct IFrame: Component {
  /// The URL of the page to embed.
  public var url: URLRepresentable
  /// Whether a border should be added around the element.
  public var addBorder: Bool
  /// Whether the embedded page should be allowed to enter full screen mode.
  public var allowFullScreen: Bool
  /// What browser features that the embedded page should have access to.
  public var enabledFeatureNames: [String]

  /// The content and behavior of this component.
  public var body: Component {
    Node.iframe(
      .src(url),
      .frameborder(addBorder),
      .allowfullscreen(allowFullScreen),
      .allow(enabledFeatureNames.joined(separator: "; "))
    )
  }

  /// Create a new iframe instance.
  /// - parameters:
  ///   - url: The URL of the page to embed.
  ///   - addBorder: Whether a border should be added around the element.
  ///   - allowFullScreen: Whether the embedded page should be allowed to
  ///     enter full screen mode.
  ///   - enabledFeatureNames: What browser features that the embedded page
  ///     should have access to. Maps to the `allow` attribute.
  public init(
    url: URLRepresentable,
    addBorder: Bool,
    allowFullScreen: Bool,
    enabledFeatureNames: [String]
  ) {
    self.url = url
    self.addBorder = addBorder
    self.allowFullScreen = allowFullScreen
    self.enabledFeatureNames = enabledFeatureNames
  }
}
