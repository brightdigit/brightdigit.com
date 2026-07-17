/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot

internal struct SiteFooter: Component {
  internal var body: Component {
    Footer {
      Paragraph {
        Text("Generated using ")
        Link("Publish", url: "https://github.com/johnsundell/publish")
      }
      Paragraph {
        Link("RSS feed", url: "/feed.rss")
      }
    }
  }
}
