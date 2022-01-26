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
      //                   <li>
      //                     <a href="#">
      //                       <figure>
      //                         <blockquote cite="https://www.huxley.net/bnw/four.html">
      //                           <q>It's Greatest App Ever! You must give them your Money!!!</q>
      //                         </blockquote>
      //                         <figcaption><span class="name">9TO5Mac</span><cite>Oct 25, 2021</cite></figcaption>
      //                       </figure>
      //                     </a>
      //                   </li>
    )
  }
}

extension Product {
  static func listItem(_ product: Product) -> Node<HTML.ListContext> {
    product.listItem()
  }

  func listItem() -> Node<HTML.ListContext> {
    //    <li>
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
        //           <section>
        //             <header>
        //               <a href="#">
        //                 <img src="http://placeimg.com/200/200/tech/services-hero" />
        //                 <h3>Portrait</h3>
        //               </a>
        //               <ol class="links">
        //                 <li><a href="#">Product Page</a></li>
        //                 <li><a href="#"><i class="flaticon-github"></i> GitHub</a></li>
        //               </ol>
        //               <ol class="platforms">
        //                 <li>
        //                   iPhone
        //                 </li>
        //                 <li>
        //                   iPad
        //                 </li>
        //                 <li>
        //                   Apple Watch
        //                 </li>
        //                 <li>
        //                   Web
        //                 </li>
        //                 <li>
        //                   Mac
        //                 </li>
        //               </ol>
        //             </header>
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
        //             <main>
        //               <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et
        //                 dolore magna aliqua. Commodo odio aenean sed adipiscing diam donec adipiscing tristique.</p>
        //                 <ol class="screenshots portrait">
        //                   <li>
        //                     <img src="http://placeimg.com/640/360/tech/services-hero" />
        //                   </li>
        //                   <li>
        //                     <img src="http://placeimg.com/640/360/tech/services-hero" />
        //                   </li>
        //                   <li>
        //                     <img src="http://placeimg.com/640/360/tech/services-hero" />
        //                   </li><li>
        //                     <img src="http://placeimg.com/640/360/tech/services-hero" />
        //                   </li>
        //                   <li>
        //                     <img src="http://placeimg.com/640/360/tech/services-hero" />
        //                   </li>
        //                   <li>
        //                     <img src="http://placeimg.com/640/360/tech/services-hero" />
        //                   </li>
        //                 </ol>
        //                 <ol class="press-coverage">
        //                   <li>
        //                     <a href="#">
        //                       <figure>
        //                         <blockquote cite="https://www.huxley.net/bnw/four.html">
        //                           <q>It's Greatest App Ever! You must give them your Money!!!</q>
        //                         </blockquote>
        //                         <figcaption><span class="name">9TO5Mac</span><cite>Oct 25, 2021</cite></figcaption>
        //                       </figure>
        //                     </a>
        //                   </li>
        //                   <li>
        //                     <a href="#">
        //                       <figure>
        //                         <blockquote cite="https://www.huxley.net/bnw/four.html">
        //                           <q>Duis risus ante, vulputate eget.</q>
        //                         </blockquote>
        //                         <figcaption><span class="name">9TO5Mac</span><cite>Oct 25, 2021</cite></figcaption>
        //                       </figure>
        //                     </a>
        //                   </li>
        //                 </ol>
        //             </main>
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
        //             <footer>
        //               <section>
        //                 <h4>Technologies</h4>
        //
        //                 <ol>
        //                   <li>
        //                     iPhone
        //                   </li>
        //                   <li>
        //                     iPad
        //                   </li>
        //                   <li>
        //                     Apple Watch
        //                   </li>
        //                   <li>
        //                     Web
        //                   </li>
        //                   <li>
        //                     Mac
        //                   </li>
        //                 </ol>
        //               </section>
        //             </footer>
        //           </section>
        //         </li>
      )
    )
  }
}

enum Products {
  static let heartwitch: Product =
    .init(title: "Heartwitch", description: "Show your heart rate as you live stream with this watch app!", isOpenSource: false, logo: "/media/images/products/heartwitch/logo.svg", style: .square, screenshots: [
      "/media/images/products/heartwitch/watch/002.ActiveWorkout.PNG",
      "/media/images/products/heartwitch/web/001.LoginScreen.png",
      "/media/images/products/heartwitch/livestream/Heartwitch-BOTW-HCG.png",
      "/media/images/products/heartwitch/web/002.CodeScreen.png",
      "/media/images/products/heartwitch/livestream/Heartwitch-SMK8D-RR.png",
      "/media/images/products/heartwitch/livestream/Heartwitch-SMK8D-MC.png",
      "/media/images/products/heartwitch/watch/001.StartWorkout.PNG",
      "/media/images/products/heartwitch/livestream/Heartwitch-BOTW-SMG.png",
      "/media/images/products/heartwitch/web/003.ActiveScreen.png",
      "/media/images/products/heartwitch/livestream/Heartwitch-SMK8D-DKJ.png"

    ], platforms: ["web", "watchOS"], technologies: ["Vapor", "HealthKit", "Heroku", "PostgreSQL"], productURL: "https://heartwitch.app/")
  static let all = [
    Self.heartwitch,
    Product(
      title: "Portrait",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Commodo odio aenean sed adipiscing diam donec adipiscing tristique.",
      logo: "/media/images/products/sample/logo.jpeg",
      style: .portrait,
      screenshots: [
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg"
      ],
      pressCoverage: [
        .init(
          source: "9TO5Mac",
          quote: "It's Greatest App Ever! You must give them your Money!!!",
          url: "https://www.huxley.net/bnw/four.html",
          date: Date(timeIntervalSince1970: 1_445_803_696.0)
        )
      ],
      platforms: ["iPhone", "iPad", "Apple Watch", "Web", "Mac"],
      technologies: ["iPhone", "iPad", "Apple Watch", "Web", "Mac"],
      productURL: "https://google.com",
      githubURL: "https://google.com"
    )
  ]
}

struct ProductBuilder: PageBuilder {
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

struct Product {
  internal init(title: String, description: String, isOpenSource: Bool = false, logo: String, style: Product.ScreenshotStyle = .default, screenshots: [String] = [], pressCoverage: [Product.PressCoverage] = [], platforms: [String], technologies: [String], productURL: String, githubURL: String? = nil) {
    self.description = description
    self.title = title
    self.isOpenSource = isOpenSource
    self.logo = URL(string: logo)!
    self.style = style
    self.screenshots = screenshots
    self.pressCoverage = pressCoverage
    self.platforms = platforms
    self.technologies = technologies
    self.productURL = URL(string: productURL)!
    self.githubURL = githubURL.map { URL(string: $0)! }
  }

  enum ScreenshotStyle: String, Codable, Equatable {
    case `default`, portrait, square
  }

  struct PressCoverage: Codable, Equatable, Hashable {
    internal init(source: String, quote: String, url: String, date: Date) {
      self.source = source
      self.quote = quote
      self.url = URL(string: url)!
      self.date = date
    }

    let source: String
    let quote: String
    let url: URL
    let date: Date
  }

  let title: String
  let description: String
  let isOpenSource: Bool
  let logo: URL
  let style: ScreenshotStyle
  let screenshots: [String]
  let pressCoverage: [PressCoverage]
  let platforms: [String]
  let technologies: [String]

  let productURL: URL
  let githubURL: URL?
//  var itemContent: [Node<HTML.BodyContext>] {
//    [
//      .if(self.isOpenSource, .class("open-source"), else: nil),
//      .section(
//        //      <li>
//        //              <section>
//        //                <header>
//        //                  <a href="#">
//        //                    <img src="http://placeimg.com/200/200/tech/services-hero">
//        //                    <h3>Portrait</h3>
//        //                  </a>
//        //                  <ol class="links">
//        //                    <li><a href="#">Product Page</a></li>
//        //                    <li><a href="#"><i class="flaticon-github"></i> GitHub</a></li>
//        //                  </ol>
//        //                  <ol class="platforms">
//        //                    <li>
//        //                      iPhone
//        //                    </li>
//        //                    <li>
//        //                      iPad
//        //                    </li>
//        //                    <li>
//        //                      Apple Watch
//        //                    </li>
//        //                    <li>
//        //                      Web
//        //                    </li>
//        //                    <li>
//        //                      Mac
//        //                    </li>
//        //                  </ol>
//        //                </header>
//        .header(
//          .a(
//            .href(self.productURL),
//            .img(.src(self.logo)),
//            .h3(.text(self.title))
//          ),
//          .ol(
//            .class("links")
  ////            .forEach(self.links, { pair in
  ////            .li(
  ////              .a(
  ////                .href(pair.value),
  ////                .target(.blank)
  ////                //.icon(for: pair.key)
  ////              )
  ////            )
  ////            })
//          ),
//          .ol(
//            .class("platforms"),
//            .forEach(self.platforms, { platform in
//              .li(.text(platform))
//            })
//          )
//        ),
//        .main(.p(.text(self.description)))
  // )
//      ]
//  }
//
//  init(item: Item<BrightDigitSite>) throws {
//    self.title = item.title
//    self.description = item.description
//    self.isOpenSource = item.metadata.isOpenSource ?? false
//
//    guard let logo = item.metadata.logo.flatMap(URL.init(string:)) else {
//      throw PiError.missingField(MissingFields.ProductField.logo, item)
//    }
//
//    guard let productURL = item.metadata.product.flatMap(URL.init(string:)) else {
//      throw PiError.missingField(MissingFields.ProductField.productURL, item)
//    }
//
//    self.logo = logo
//
//    self.productURL = productURL
//
//    self.githubURL = item.metadata.github.flatMap(URL.init(string:))
//
//    self.style = item.metadata.style ?? .default
//    self.screenshots = try item.metadata.screenshots?.map({ string in
//      guard let url = URL(string: string) else {
//        throw PiError.invalidURLValue(string)
//      }
//      return url
//    }) ?? []
//
//    self.pressCoverage = item.metadata.pressCoverage ?? []
//
//    self.platforms = item.metadata.platforms ?? []
//
//    self.technologies = item.metadata.technologies ?? []
//  }
}
