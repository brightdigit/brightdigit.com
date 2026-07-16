/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot

internal struct SiteHeader<Site: Website>: Component {
  internal var context: PublishingContext<Site>
  internal var selectedSectionID: Site.SectionID?

  internal var body: Component {
    Header {
      Wrapper {
        Link(context.site.name, url: "/")
          .class("site-name")

        if Site.SectionID.allCases.count > 1 {
          navigation
        }
      }
    }
  }

  private var navigation: Component {
    Navigation {
      List(Site.SectionID.allCases) { sectionID in
        let section = context.sections[sectionID]

        return Link(
          section.title,
          url: section.path.absoluteString
        )
        .class(sectionID == selectedSectionID ? "selected" : "")
      }
    }
  }
}
