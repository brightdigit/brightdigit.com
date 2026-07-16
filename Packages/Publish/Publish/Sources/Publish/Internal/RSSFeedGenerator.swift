/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Foundation
import Plot

internal struct RSSFeedGenerator<Site: Website> {
  internal let includedSectionIDs: Set<Site.SectionID>
  internal let itemPredicate: Predicate<Item<Site>>?
  internal let config: RSSFeedConfiguration
  internal let context: PublishingContext<Site>
  internal let date: Date

  internal func generate() async throws {
    let outputFile = try context.createOutputFile(at: config.targetPath)
    let cacheFile = try context.cacheFile(named: "feed")
    let oldCache = try? cacheFile.read().decoded() as Cache
    var items = [Item<Site>]()

    for sectionID in includedSectionIDs {
      items += context.sections[sectionID].items
    }

    items.sort { $0.date > $1.date }

    if let predicate = itemPredicate?.inverse() {
      items.removeAll(where: predicate.matches)
    }

    if let date = context.lastGenerationDate, let cache = oldCache {
      if cache.config == config, cache.itemCount == items.count {
        let newlyModifiedItem = items.first { $0.lastModified > date }

        guard newlyModifiedItem != nil else {
          return try outputFile.write(cache.feed)
        }
      }
    }

    let feed = await makeFeed(containing: items).render(indentedBy: config.indentation)

    let newCache = Cache(config: config, feed: feed, itemCount: items.count)
    try cacheFile.write(newCache.encoded())
    try outputFile.write(feed)
  }
}

extension RSSFeedGenerator {
  fileprivate struct Cache: Codable {
    let config: RSSFeedConfiguration
    let feed: String
    let itemCount: Int
  }

  fileprivate func makeFeed(containing items: [Item<Site>]) async -> RSS {
    RSS(
      .title(context.site.name),
      .description(context.site.description),
      .link(context.site.url),
      .language(context.site.language),
      .lastBuildDate(date, timeZone: context.dateParseStrategy.timeZone),
      .pubDate(date, timeZone: context.dateParseStrategy.timeZone),
      .ttl(Int(config.ttlInterval)),
      .atomLink(context.site.url(for: config.targetPath)),
      .group(
        items.prefix(config.maximumItemCount).map { item in
          .item(
            .guid(for: item, site: context.site),
            .title(item.rssTitle),
            .description(item.description),
            .link(item.rssProperties.link ?? context.site.url(for: item)),
            .pubDate(item.date, timeZone: context.dateParseStrategy.timeZone),
            .content(for: item, site: context.site)
          )
        }
      )
    )
  }
}
