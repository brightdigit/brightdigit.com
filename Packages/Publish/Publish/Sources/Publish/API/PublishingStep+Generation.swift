/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Foundation
import Plot

// MARK: - Generation

extension PublishingStep {
  /// Generate the website's HTML using a given theme.
  /// - Parameters:
  ///   - theme: The theme to use to generate the website's HTML.
  ///   - indentation: How each HTML file should be indented.
  ///   - fileMode: The mode to use when generating each HTML file.
  /// - Returns: The configured publishing step.
  public static func generateHTML(
    withTheme theme: Theme<Site>,
    indentation: Indentation.Kind? = nil,
    fileMode: HTMLFileMode = .foldersAndIndexFiles
  ) -> Self {
    step(named: "Generate HTML") { context in
      let generator = HTMLGenerator(
        theme: theme,
        indentation: indentation,
        fileMode: fileMode,
        context: context
      )

      try await generator.generate()
    }
  }

  /// Generate an RSS feed for the website.
  /// - Parameters:
  ///   - includedSectionIDs: The IDs of the sections which items
  ///       to include when generating the feed.
  ///   - itemPredicate: A predicate used to determine whether to
  ///       include a given item within the generated feed (default: include all).
  ///   - config: The configuration to use when generating the feed.
  ///   - date: The date that should act as the build and publishing
  ///       date for the generated feed (default: the current date).
  /// - Returns: The configured publishing step.
  public static func generateRSSFeed(
    including includedSectionIDs: Set<Site.SectionID>,
    itemPredicate: Predicate<Item<Site>>? = nil,
    config: RSSFeedConfiguration = .default,
    date: Date = Date()
  ) -> Self {
    guard !includedSectionIDs.isEmpty else {
      return .empty
    }

    return step(named: "Generate RSS feed") { context in
      let generator = RSSFeedGenerator(
        includedSectionIDs: includedSectionIDs,
        itemPredicate: itemPredicate,
        config: config,
        context: context,
        date: date
      )

      try await generator.generate()
    }
  }

  /// Generate a site map for the website, which is an XML file used
  /// for search engine indexing.
  /// - Parameters:
  ///   - excludedPaths: Any paths to exclude from the site map.
  ///       Adding a section's path to the list removes the entire section, including all its items.
  ///   - indentation: How the site map should be indented.
  /// - Returns: The configured publishing step.
  public static func generateSiteMap(
    excluding excludedPaths: Set<Path> = [],
    indentedBy indentation: Indentation.Kind? = nil
  ) -> Self {
    step(named: "Generate site map") { context in
      let generator = SiteMapGenerator(
        excludedPaths: excludedPaths,
        indentation: indentation,
        context: context
      )

      try generator.generate()
    }
  }
}

extension PublishingStep where Site.ItemMetadata: PodcastCompatibleWebsiteItemMetadata {
  /// Generate a podcast feed for one of the website's sections.
  /// Note that all of the items within the given section must define `podcast`
  /// and `audio` metadata, or an error will be thrown.
  /// - Parameters:
  ///   - section: The section to generate a podcast feed for.
  ///   - itemPredicate: A predicate used to determine whether to
  ///       include a given item within the generated feed (default: include all).
  ///   - config: The configuration to use when generating the feed.
  ///   - date: The date that should act as the build and publishing
  ///       date for the generated feed (default: the current date).
  /// - Returns: The configured publishing step.
  public static func generatePodcastFeed(
    for section: Site.SectionID,
    itemPredicate: Predicate<Item<Site>>? = nil,
    config: PodcastFeedConfiguration<Site>,
    date: Date = Date()
  ) -> Self {
    step(named: "Generate podcast feed") { context in
      let generator = PodcastFeedGenerator(
        sectionID: section,
        itemPredicate: itemPredicate,
        config: config,
        context: context,
        date: date
      )

      try await generator.generate()
    }
  }
}
