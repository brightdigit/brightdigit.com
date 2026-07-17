/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot

internal struct SiteMapGenerator<Site: Website> {
  internal let excludedPaths: Set<Path>
  internal let indentation: Indentation.Kind?
  internal let context: PublishingContext<Site>

  internal func generate() throws {
    let sections = context.sections.sorted {
      $0.id.rawValue < $1.id.rawValue
    }

    let pages = context.pages.values.sorted {
      $0.path < $1.path
    }

    let siteMap = makeSiteMap(for: sections, pages: pages, site: context.site)
    let xml = siteMap.render(indentedBy: indentation)
    let file = try context.createOutputFile(at: "sitemap.xml")
    try file.write(xml)
  }
}

extension SiteMapGenerator {
  fileprivate func shouldIncludePath(_ path: Path) -> Bool {
    !excludedPaths.contains(where: {
      path.string.hasPrefix($0.string)
    })
  }

  fileprivate func makeSiteMap(for sections: [Section<Site>], pages: [Page], site: Site) -> SiteMap
  {
    SiteMap(
      .forEach(sections) { section in
        guard shouldIncludePath(section.path) else {
          return .empty
        }

        return .group(
          .url(
            .loc(site.url(for: section)),
            .changefreq(.daily),
            .priority(1.0),
            .lastmod(
              max(
                section.lastModified,
                section.lastItemModificationDate ?? .distantPast
              )
            )
          ),
          .forEach(section.items) { item in
            guard shouldIncludePath(item.path) else {
              return .empty
            }

            return .url(
              .loc(site.url(for: item)),
              .changefreq(.monthly),
              .priority(0.5),
              .lastmod(item.lastModified)
            )
          }
        )
      },
      .forEach(pages) { page in
        guard shouldIncludePath(page.path) else {
          return .empty
        }

        return .url(
          .loc(site.url(for: page)),
          .changefreq(.monthly),
          .priority(0.5),
          .lastmod(page.lastModified)
        )
      }
    )
  }
}
