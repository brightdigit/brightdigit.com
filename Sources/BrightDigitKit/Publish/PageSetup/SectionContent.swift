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

      .section(
        .ol(
          .forEach(builder.children) { .li(
            .forEach($0.sectionItemContent) { $0 }
          ) }
        )
      )
    ]
  }

  // I need to rename this, if it's a newsletter we'll have to do something special, vs if it's not it's organized differently
  var newsLetterHeaderNode: Node<HTML.BodyContext> {
    if builder.section.id == .newsletters {
      return .header(
        .section(
          .h1("Don't Let Your App", .em("Fall Behind")),
          .p("\(Strings.Newsletter.featuredParagraph)")
        )
      )
    } else {
      return .header(
        .section(
          .class("hero"),
          .section(
            .class("featured"),
            .forEach(builder.featuredItem.featuredItemContent) { $0 }
          )
        )
      )
    }
  }
}
