import Foundation
import Plot
import Publish
import PublishType

extension NewsletterItem {
  internal var formNode: Node<HTML.BodyContext> {
    .form(
      .attribute(named: "name", value: "subscribers"),
      .method(.post),
      .attribute(named: "data-netlify", value: "true"),
      .div(
        .div(
          .input(
            .type(.text),
            .placeholder("leo@brightdigit.com"),
            .name("email")),
          .label("Email")
        )
      ),
      .div(
        .div(
          .button("Sign me up!", .type(.submit))
        )
      ),
      .div(
        .class("message"),
        .div(
          .h3("Be the first to know:"),
          .ol(
            .li(
              "When we publish", .b(" new content "),
              "on building better apps on our blog or podcast."),
            .li(
              "Details about", .b(" upcoming events and conferences "),
              "Leo is speaking at."),
            .li(
              "About the", .b(" latest developments "),
              "in the world of Swift and Apple software, and how they can help you.")
          )
        )
      )
    )
  }

  internal var featuredItemContent: Node<HTML.BodyContext> {
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
          .header(
            .h3("Featured issue"),
            .img(.src(featuredImageURL)),
            .a(
              .href(archiveURL),
              .h2(.text(title))
            )
          ),
          .main(
            .text(description)
          ),
          .footer(
            .text("published on"),
            .span(
              .class("published-date"),
              .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
            )
          )
        )
      )
    )
  }

  internal var sectionItemContent: [Node<HTML.BodyContext>] {
    [
      .id("issue-\(issueNo)"),
      .header(
        .img(.src(featuredImageURL)),
        .a(
          .href(archiveURL),
          .h2(.text(title))
        )
      ),
      .main(
        .text(description)
      ),
      .footer(
        .text("published on"),
        .span(
          .class("published-date"),
          .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
        )
      ),
    ]
  }
}
