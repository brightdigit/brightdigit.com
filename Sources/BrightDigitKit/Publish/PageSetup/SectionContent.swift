import Foundation
import Plot
import Publish

struct SectionContent<SectionBuilderType: SectionBuilderProtocol>: PageContent {
  var description: String {
    builder.description
  }

  var socialTitle: String {
    builder.section.title
  }

  var socialImageURL: URL {
    if builder.featuredItem.featuredImageURL.path.isEmpty {
      return builder.featuredItem.featuredImageURL.absoluteURL
    } else {
      let path = Path(builder.featuredItem.featuredImageURL.path)
      return context.site.url(for: path)
    }
  }

  var absoluteURL: URL {
    context.site.url(for: builder.section)
  }

  let builder: SectionBuilderType
  let context: PublishingContext<BrightDigitSite>

  var title: String {
    builder.section.title
  }

  var bodyClasses: [String] {
    []
  }

  var bodyID: String? {
    builder.section.id.rawValue
  }

  var main: [Node<HTML.BodyContext>] {
    [
      .class("section"),

      featuredNode,

      .section(
        .ol(
          .forEach(builder.children) { .li(
            .forEach($0.sectionItemContent) { $0 }
          ) }
        )
      )
    ]
  }

  var featuredNode: Node<HTML.BodyContext> {
    builder.featuredItem.featuredItemContent
  }

  var redirectURL: URL? {
    nil
  }
}
