import Foundation
import Plot
import Publish

extension Product.PressCoverage {
  static func listItem(_ pressCoverage: Self) -> Node<HTML.ListContext> {
    .li(
      .a(.href(pressCoverage.url), .target(.blank),
         .element(named: "figure", nodes: [
           .blockquote(
             .attribute(named: "cite", value: pressCoverage.url.absoluteString),
             .p(.text(pressCoverage.quote))
           ),
           .element(named: "figcaption", nodes: [
             .span(
               .class("name"),
               .text("9To5Mac")
             ),
             .element(named: "cite", text: PiHTMLFactory.itemFormatter.string(from: pressCoverage.date))
           ])
         ]))
    )
  }
}

extension Product {
  static func listItem(_ product: Product) -> Node<HTML.ListContext> {
    product.listItem()
  }

  func listItem() -> Node<HTML.ListContext> {
    .li(
      .section(
        .header(
          .a(
            .href(productURL),
            .target(.blank),
            .img(.src(logo)),
            .h3(.text(title))
          ),
          .ol(
            .class("links"),
            .li(
              .a(
                .href(productURL),
                .target(.blank),
                .text("Product Page")
              )
            ),
            .unwrap(githubURL) { githubURL in
              .li(
                .a(
                  .href(githubURL),
                  .target(.blank),
                  .i(.class("flaticon-github")),
                  .text("GitHub")
                )
              )
            }
          ),
          .ol(
            .class("platforms"),
            .forEach(platforms) { platform in
              .li(.text(platform))
            }
          )
        ),
        .main(
          .p(.text(description)),
          .ol(
            .class("screenshots \(style.rawValue)"),
            .forEach(screenshots) { screenshotURL in
              .li(
                .img(.src(screenshotURL))
              )
            }
          ),
          .ol(
            .class("press-coverage"),
            .forEach(pressCoverage, PressCoverage.listItem)
          )
        ),
        .footer(
          .section(
            .h4(.text("Technologies")),
            .ol(
              .forEach(technologies) { tech in
                .li(.text(tech))
              }
            )
          )
        )
      )
    )
  }
}


struct ProductsBuilder: PageBuilder {
  internal init(products: [Product] = Products.all) {
    self.products = products
  }

  let products: [Product]
  func main(forLocation _: Page, withContext _: PublishingContext<BrightDigitSite>) -> [Node<HTML.BodyContext>] {
    [
      .ol(
        .forEach(products, Product.listItem)
      )
    ]
  }
}

