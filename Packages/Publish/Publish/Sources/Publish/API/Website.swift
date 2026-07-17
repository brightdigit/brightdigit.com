/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Dispatch
import Foundation
import Plot
import Synchronization

/// Protocol used to define a Publish-based website.
/// You conform to this protocol using a custom type, which is then used to
/// infer various information about your website when generating its various
/// HTML pages and resources. A website is then published using a pipeline made
/// up of `PublishingStep` values, which is constructed using the `publish` method.
/// To generate the necessary bootstrapping for conforming to this protocol, use
/// the `publish new` command line tool.
public protocol Website: Sendable {
  /// The enum type used to represent the website's section IDs.
  associatedtype SectionID: WebsiteSectionID
  /// The type that defines any custom metadata for the website.
  associatedtype ItemMetadata: WebsiteItemMetadata

  /// The absolute URL that the website will be hosted at.
  var url: URL { get }
  /// The name of the website.
  var name: String { get }
  /// A description of the website.
  var description: String { get }
  /// The website's primary language.
  var language: Language { get }
  /// Any path to an image that represents the website.
  var imagePath: Path? { get }
  /// The website's favicon, if any.
  var favicon: Favicon? { get }
  /// The configuration to use when generating tag HTML for the website.
  /// If this is `nil`, then no tag HTML will be generated.
  var tagHTMLConfig: TagHTMLConfiguration? { get }
}

// MARK: - Defaults

extension Website {
  /// The website's favicon. Defaults to a standard favicon.
  public var favicon: Favicon? { .init() }
  /// The configuration to use when generating tag HTML. Defaults to `.default`.
  public var tagHTMLConfig: TagHTMLConfiguration? { .default }
}

// MARK: - Paths and URLs

extension Website {
  /// The path for the website's tag list page.
  public var tagListPath: Path {
    tagHTMLConfig?.basePath ?? .defaultForTagHTML
  }

  /// Return the relative path for a given section ID.
  /// - parameter sectionID: The section ID to return a path for.
  /// - Returns: The relative path.
  public func path(for sectionID: SectionID) -> Path {
    Path(sectionID.rawValue)
  }

  /// Return the relative path for a given tag.
  /// - parameter tag: The tag to return a path for.
  /// - Returns: The relative path.
  public func path(for tag: Tag) -> Path {
    let basePath = tagHTMLConfig?.basePath ?? .defaultForTagHTML
    return basePath.appendingComponent(tag.normalizedString())
  }

  /// Return the absolute URL for a given tag.
  /// - Returns: The absolute URL.
  /// - parameter tag: The tag to return a URL for.
  public func url(for tag: Tag) -> URL {
    url(for: path(for: tag))
  }

  /// Return the absolute URL for a given path.
  /// - parameter path: The path to return a URL for.
  /// - Returns: The absolute URL.
  public func url(for path: Path) -> URL {
    guard !path.string.isEmpty else {
      return url
    }
    return url.appendingPathComponent(path.string)
  }

  /// Return the absolute URL for a given location.
  /// - parameter location: The location to return a URL for.
  /// - Returns: The absolute URL.
  public func url(for location: Location) -> URL {
    url(for: location.path)
  }
}
