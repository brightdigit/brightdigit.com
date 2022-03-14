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
    .header(
      .section(
        .h1("Don't Let Your App", .em("Fall Behind")),
        .p("\(Strings.Newsletter.featuredParagraph)")
      ),
      .section(
        .class("hero"),

        formNode,

        .section(
          .class("featured"),
          .forEach(builder.featuredItem.featuredItemContent) { $0 }
        )
      )
    )
  }

  var formNode: Node<HTML.BodyContext> {
    .form(
      .div(
        .div(
          .input(.type(.text), .placeholder("leo@brightdigit.com")),
          .label("Email")
        )
      ),
      .div(
        .div(
          .button("Sign me up!")
        )
      ),
      .div(
        .class("message"),
        .div(
          .h3("Be the first to know:"),
          .ol(
            .li("When we publish", .b(" new content "), "on building better apps on our blog or podcast."),
            .li("Details about", .b(" upcoming events and conferences "), "Leo is speaking at."),
            .li("About the", .b(" latest developments "), "in the world of Swift and Apple software, and how they can help you.")
          )
        )
      )
    )
  }
}
