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
    return .header(
      .section(
        .h1("Don't Let Your App", .em("Fall Behind")),
        .p("\(Strings.Newsletter.featuredParagraph)")
      ),
      .section(
        .class("hero"),
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
                .li("When we publish new content", .b(" new content "), "on building better apps on our blog or podcast.")
              )
            )
          )
        ),
        .section(
          .class("featured"),
          .forEach(builder.featuredItem.featuredItemContent) { $0 }
        )
      )
    )
    
  }
}
