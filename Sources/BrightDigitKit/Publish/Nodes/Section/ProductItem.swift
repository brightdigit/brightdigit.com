import Foundation
import Plot
import Publish

struct ProductItem: SectionItem {
  let description: String
  let title: String

  var itemContent: [Node<HTML.BodyContext>] {
    [
      .id("product"),
      .header(
        // .img(.src(featuredImageURL)),
        .a(
          // .href(archiveURL),
          .h2(.text(title))
        )
      ),
      .main(
        .text(description)
      ),
      .footer(
        .a(
          .text("test")
        )
      )
    ]
  }

  init(item: Item<BrightDigitSite>) throws {
    let featuredImageURL = item.metadata.featuredImage.flatMap(URL.init(string:))
    let archiveURL = item.metadata.longArchiveURL.flatMap(URL.init(string:))
    let isFeatured = item.metadata.featured ?? false
    let issueNo = item.metadata.issueNo.flatMap(Int.init)

    title = item.title
    description = item.description
  }
}
