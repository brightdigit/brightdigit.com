/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot

/// Type used to implement an HTML theme.
/// When implementing reusable themes that are vended as frameworks or APIs,
/// it's recommended to create them using static factory methods, just like
/// how the built-in `foundation` theme is implemented.
public struct Theme<Site: Website>: Sendable {
  internal let makeIndexHTML: @Sendable (Index, PublishingContext<Site>) throws -> HTML
  internal let makeSectionHTML: @Sendable (Section<Site>, PublishingContext<Site>) throws -> HTML
  internal let makeItemHTML: @Sendable (Item<Site>, PublishingContext<Site>) throws -> HTML
  internal let makePageHTML: @Sendable (Page, PublishingContext<Site>) throws -> HTML
  internal let makeTagListHTML: @Sendable (TagListPage, PublishingContext<Site>) throws -> HTML?
  internal let makeTagDetailsHTML:
    @Sendable (TagDetailsPage, PublishingContext<Site>) throws -> HTML?
  internal let resourcePaths: Set<Path>
  internal let creationPath: Path

  /// Create a new theme instance.
  /// - Parameters:
  ///   - factory: The HTML factory to use to create the theme's HTML.
  ///   - resources: A set of paths to any resources that the theme uses.
  ///       These resources will be copied into the website's output folder before
  ///       the theme is used, and should be relative to the root folder of the Swift
  ///       package that this theme is defined in.
  ///   - file: The file that this method is called from (auto-inserted).
  public init<T: HTMLFactory>(
    htmlFactory factory: T,
    resourcePaths resources: Set<Path> = [],
    file: StaticString = #filePath
  ) where T.Site == Site {
    makeIndexHTML = { try factory.makeIndexHTML(for: $0, context: $1) }
    makeSectionHTML = { try factory.makeSectionHTML(for: $0, context: $1) }
    makeItemHTML = { try factory.makeItemHTML(for: $0, context: $1) }
    makePageHTML = { try factory.makePageHTML(for: $0, context: $1) }
    makeTagListHTML = { try factory.makeTagListHTML(for: $0, context: $1) }
    makeTagDetailsHTML = { try factory.makeTagDetailsHTML(for: $0, context: $1) }
    resourcePaths = resources
    creationPath = Path("\(file)")
  }
}
