/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Ink
import Plot

extension Node where Context == HTML.DocumentContext {
  /// Add an HTML `<head>` tag within the current context, based
  /// on inferred information from the current location and `Website`
  /// implementation.
  /// - Parameters:
  ///   - location: The location to generate a `<head>` tag for.
  ///   - site: The website on which the location is located.
  ///   - titleSeparator: Any string to use to separate the location's
  ///       title from the name of the website. Default: `" | "`.
  ///   - stylesheetPaths: The paths to any stylesheets to add to
  ///       the resulting HTML page. Default: `styles.css`.
  ///   - rssFeedPath: The path to any RSS feed to associate with the
  ///       resulting HTML page. Default: `feed.rss`.
  ///   - rssFeedTitle: An optional title for the page's RSS feed.
  /// - Returns: A node representing the page’s `<head>` element.
  public static func head<T: Website>(
    for location: Location,
    on site: T,
    titleSeparator: String = " | ",
    stylesheetPaths: [Path] = ["/styles.css"],
    rssFeedPath: Path? = .defaultForRSSFeed,
    rssFeedTitle: String? = nil
  ) -> Node {
    var title = location.title

    if title.isEmpty {
      title = site.name
    } else {
      title.append(titleSeparator + site.name)
    }

    var description = location.description

    if description.isEmpty {
      description = site.description
    }

    return .head(
      .encoding(.utf8),
      .siteName(site.name),
      .url(site.url(for: location)),
      .title(title),
      .description(description),
      .twitterCardType(location.imagePath == nil ? .summary : .summaryLargeImage),
      .forEach(stylesheetPaths, { .stylesheet($0) }),
      .viewport(.accordingToDevice),
      .unwrap(site.favicon, { .favicon($0) }),
      .unwrap(
        rssFeedPath,
        { path in
          let title = rssFeedTitle ?? "Subscribe to \(site.name)"
          return .rssFeedLink(path.absoluteString, title: title)
        }
      ),
      .unwrap(
        location.imagePath ?? site.imagePath,
        { path in
          let url = site.url(for: path)
          return .socialImageLink(url)
        }
      )
    )
  }
}

extension Node where Context == HTML.HeadContext {
  /// Link the HTML page to an external CSS stylesheet.
  /// - parameter path: The absolute path of the stylesheet to link to.
  /// - Returns: A node linking the given stylesheet.
  public static func stylesheet(_ path: Path) -> Node {
    .stylesheet(path.absoluteString)
  }

  /// Declare a favicon for the HTML page.
  /// - parameter favicon: The favicon to declare.
  /// - Returns: A node declaring the given favicon.
  public static func favicon(_ favicon: Favicon) -> Node {
    .favicon(favicon.path.absoluteString, type: favicon.type)
  }
}

extension Node where Context: HTML.BodyContext {
  /// Render a location's `Content.Body` as HTML within the current context.
  /// - Returns: A node containing the rendered content body.
  /// - parameter body: The body to render.
  public static func contentBody(_ body: Content.Body) -> Node {
    .raw(body.html)
  }

  /// Render a string of inline Markdown as HTML within the current context.
  /// - Parameters:
  ///   - markdown: The Markdown string to render.
  ///   - parser: The Markdown parser to use. Pass `context.markdownParser` to
  ///       use the same Markdown parser as the main publishing process is using.
  /// - Returns: A node containing the rendered Markdown.
  public static func markdown(
    _ markdown: String,
    using parser: MarkdownParser = .init()
  ) -> Node {
    .raw(parser.html(from: markdown))
  }

  /// Add an inline audio player within the current context.
  /// - Parameters:
  ///   - audio: The audio to add a player for.
  ///   - showControls: Whether playback controls should be shown to the user.
  /// - Returns: A node containing the audio player.
  public static func audioPlayer(
    for audio: Audio,
    showControls: Bool = true
  ) -> Node {
    AudioPlayer(
      audio: audio,
      showControls: showControls
    )
    .convertToNode()
  }

  /// Add an inline video player within the current context.
  /// - Parameters:
  ///   - video: The video to add a player for.
  ///   - showControls: Whether playback controls should be shown to the user.
  ///       Note that this parameter is only relevant for hosted videos.
  /// - Returns: A node with the resolved `href` attribute.
  public static func videoPlayer(
    for video: Video,
    showControls: Bool = true
  ) -> Node {
    VideoPlayer(
      video: video,
      showControls: showControls
    )
    .convertToNode()
  }
}

extension Node where Context: HTMLLinkableContext {
  /// Assign a path to link the element to, using its `href` attribute.
  /// - parameter path: The absolute path to assign.
  /// - Returns: A node with the resolved `href` attribute.
  public static func href(_ path: Path) -> Node {
    .href(path.absoluteString)
  }
}

extension Attribute where Context: HTMLSourceContext {
  /// Assign a source to the element, using its `src` attribute.
  /// - parameter path: The source path to assign.
  /// - Returns: An attribute with the resolved `src` value.
  public static func src(_ path: Path) -> Attribute {
    .src(path.absoluteString)
  }
}
