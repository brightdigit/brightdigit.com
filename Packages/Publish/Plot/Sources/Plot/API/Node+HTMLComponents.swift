/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Node where Context == HTML.HeadContext {
  /// Declare that the HTML page is encoded using a certain encoding.
  /// - parameter encoding: The encoding to declare. See `DocumentEncoding`.
  /// - Returns: The created node.
  public static func encoding(_ encoding: DocumentEncoding) -> Node {
    .meta(.charset(encoding))
  }

  /// Link the HTML page to an external CSS stylesheet.
  /// - Parameters:
  ///   - url: The URL of the stylesheet to link to.
  ///   - integrity: optional base64-encoded cryptographic hash
  /// - Returns: The created node.
  public static func stylesheet(_ url: URLRepresentable, integrity: String? = nil) -> Node {
    .link(
      .rel(.stylesheet),
      .href(url.string),
      .type("text/css"),
      .unwrap(integrity, Attribute.integrity)
    )
  }

  /// Declare the HTML page's canonical URL, for social sharing and SEO.
  /// - parameter url: The URL to declare as this document's canonical URL.
  /// - Returns: The created node.
  public static func url(_ url: URLRepresentable) -> Node {
    let url = url.string

    return .group([
      .link(.rel(.canonical), .href(url)),
      .meta(.name("twitter:url"), .content(url)),
      .meta(.property("og:url"), .content(url)),
    ])
  }

  /// Declare the name of the site that this HTML page belongs to.
  /// - parameter name: The name to declare.
  /// - Returns: The created node.
  public static func siteName(_ name: String) -> Node {
    .meta(.property("og:site_name"), .content(name))
  }

  /// Declare the HTML page's title, both for browsers and for social sharing.
  /// - parameter title: The title to declare.
  /// - Returns: The created node.
  public static func title(_ title: String) -> Node {
    .group([
      .element(named: "title", text: title),
      .meta(.name("twitter:title"), .content(title)),
      .meta(.property("og:title"), .content(title)),
    ])
  }

  /// Declare a description of the HTML page, for social sharing and SEO.
  /// - parameter text: A text that describes the page's content.
  /// - Returns: The created node.
  public static func description(_ text: String) -> Node {
    .group([
      .meta(.name("description"), .content(text)),
      .meta(.name("twitter:description"), .content(text)),
      .meta(.property("og:description"), .content(text)),
    ])
  }

  /// Declare a URL to an image that should be displayed when the HTML page
  /// is shared on a social media website or app.
  /// - parameter url: The URL to declare. Should be an absolute URL.
  /// - Returns: The created node.
  public static func socialImageLink(_ url: URLRepresentable) -> Node {
    let url = url.string

    return .group([
      .meta(.name("twitter:image"), .content(url)),
      .meta(.property("og:image"), .content(url)),
    ])
  }

  /// Declare which card type that Twitter should use when displaying a link
  /// to this HTML page. See `TwitterCardType` for more details.
  /// - parameter type: The type of Twitter card to use for this page.
  /// - Returns: The created node.
  public static func twitterCardType(_ type: TwitterCardType) -> Node {
    .meta(.name("twitter:card"), .content(type.rawValue))
  }

  /// Declare the Twitter handle of the site that Twitter should use when displaying a link
  /// - parameter username: The handle of the account on Twitter. For example: `@SwiftBySundell`
  /// - Returns: The created node.
  public static func twitterUsername(_ username: String) -> Node {
    .meta(.name("twitter:site"), .content(username))
  }

  /// Declare how the page should behave in terms of viewport responsiveness.
  /// This declaration is important when building HTML pages for display on
  /// mobile devices, as it determines how the page's content will scale.
  /// - Parameters:
  ///   - widthMode: How the viewport's width should scale according
  ///     to the device the page is being rendered on. See `HTMLViewportWidthMode`.
  ///   - initialScale: The initial scale that the page should use.
  ///   - fit: How the viewport should be laid out on screen in relation
  ///     to the screen’s safe area insets. See `HTMLViewportFitMode`.
  /// - Returns: The created node.
  public static func viewport(
    _ widthMode: HTMLViewportWidthMode,
    initialScale: Double = 1,
    fit: HTMLViewportFitMode? = nil
  ) -> Node {
    var content = "width=\(widthMode.string), initial-scale=\(initialScale)"
    if let fit = fit {
      content += ", viewport-fit=\(fit.rawValue)"
    }
    return .meta(.name("viewport"), .content(content))
  }

  /// Declare a "favicon" (a small icon typically displayed along the website's
  /// title in various browser UIs) for the HTML page.
  /// - Parameters:
  ///   - url: The favicon's URL.
  ///   - type: The MIME type of the image (default: "image/png").
  /// - Returns: The created node.
  public static func favicon(_ url: URLRepresentable, type: String = "image/png") -> Node {
    .link(.rel(.shortcutIcon), .href(url.string), .type(type))
  }

  /// Declare a url to an RSS feed to associate with this HTML page.
  /// - Parameters:
  ///   - url: The URL to the RSS feed.
  ///   - title: An optional title that some RSS readers will display
  ///     for the feed.
  /// - Returns: The created node.
  public static func rssFeedLink(_ url: URLRepresentable, title: String? = nil) -> Node {
    .link(
      .rel(.alternate),
      .href(url.string),
      .type("application/rss+xml"),
      .attribute(named: "title", value: title)
    )
  }
}
