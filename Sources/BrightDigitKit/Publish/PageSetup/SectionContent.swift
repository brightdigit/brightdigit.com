import Foundation
import Plot
import Publish

struct SectionContent<SectionBuilderType: SectionBuilderProtocol>: PageContent {
  let builder: SectionBuilderType

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

      newsLetterHeaderNode,

      .header(
        .section(
          .class("hero"),
          .section(
            .class("featured"),
            .forEach(builder.featuredItem.featuredItemContent) { $0 }
          )
        )
      ),

      .section(
        .ol(
          .forEach(builder.children) { .li(
            .forEach($0.sectionItemContent) { $0 }
          ) }
        )
      )
    ]
  }

  var newsLetterHeaderNode: Node<HTML.BodyContext> {
    if builder.section.id == .newsletters {
      return .header(
        .section(
          .h1("Don't Let Your App", .em("Fall Behind")),
          .p("\(Strings.Newsletter.featuredParagraph)")
        )
      )
    } else {
      return .p("") // an extra blank paragraph, if this isn't a newsletter
    }
  }
}
