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

      headerNode,

      .section(
        .ol(
          .forEach(builder.children) { .li(
            .forEach($0.sectionItemContent) { $0 }
          ) }
        )
      )
    ]
  }

  var headerNode: Node<HTML.BodyContext> {
    if builder.section.id == .newsletters {
      return .header(
        .section(
          .h1("NEWSLETTER!!")
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
