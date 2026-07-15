/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot

internal struct FoundationHTMLFactory<Site: Website>: HTMLFactory {
  internal func makeIndexHTML(
    for index: Index,
    context: PublishingContext<Site>
  ) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: index, on: context.site),
      .body {
        SiteHeader(context: context, selectedSectionID: nil)
        Wrapper {
          H1(index.title)
          Paragraph(context.site.description)
            .class("description")
          H2("Latest content")
          ItemList(
            items: context.allItems(
              sortedBy: \.date,
              order: .descending
            ),
            site: context.site
          )
        }
        SiteFooter()
      }
    )
  }

  internal func makeSectionHTML(
    for section: Section<Site>,
    context: PublishingContext<Site>
  ) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: section, on: context.site),
      .body {
        SiteHeader(context: context, selectedSectionID: section.id)
        Wrapper {
          H1(section.title)
          ItemList(items: section.items, site: context.site)
        }
        SiteFooter()
      }
    )
  }

  internal func makeItemHTML(
    for item: Item<Site>,
    context: PublishingContext<Site>
  ) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: item, on: context.site),
      .body(
        .class("item-page"),
        .components {
          SiteHeader(context: context, selectedSectionID: item.sectionID)
          Wrapper {
            Article {
              Div(item.content.body).class("content")
              Span("Tagged with: ")
              ItemTagList(item: item, site: context.site)
            }
          }
          SiteFooter()
        }
      )
    )
  }

  internal func makePageHTML(
    for page: Page,
    context: PublishingContext<Site>
  ) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: page, on: context.site),
      .body {
        SiteHeader(context: context, selectedSectionID: nil)
        Wrapper(page.body)
        SiteFooter()
      }
    )
  }

  internal func makeTagListHTML(
    for page: TagListPage,
    context: PublishingContext<Site>
  ) throws -> HTML? {
    HTML(
      .lang(context.site.language),
      .head(for: page, on: context.site),
      .body {
        SiteHeader(context: context, selectedSectionID: nil)
        Wrapper {
          H1("Browse all tags")
          List(page.tags.sorted()) { tag in
            ListItem {
              Link(
                tag.string,
                url: context.site.path(for: tag).absoluteString
              )
            }
            .class("tag")
          }
          .class("all-tags")
        }
        SiteFooter()
      }
    )
  }

  internal func makeTagDetailsHTML(
    for page: TagDetailsPage,
    context: PublishingContext<Site>
  ) throws -> HTML? {
    HTML(
      .lang(context.site.language),
      .head(for: page, on: context.site),
      .body {
        SiteHeader(context: context, selectedSectionID: nil)
        Wrapper {
          H1 {
            Text("Tagged with ")
            Span(page.tag.string).class("tag")
          }

          Link(
            "Browse all tags",
            url: context.site.tagListPath.absoluteString
          )
          .class("browse-all")

          ItemList(
            items: context.items(
              taggedWith: page.tag,
              sortedBy: \.date,
              order: .descending
            ),
            site: context.site
          )
        }
        SiteFooter()
      }
    )
  }
}
