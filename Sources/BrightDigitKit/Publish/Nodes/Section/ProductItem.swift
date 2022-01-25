import Foundation
import Plot
import Publish

struct ProductItem: SectionItem {

  
  
  enum ScreenshotStyle : String, Codable, Equatable {
    case `default`,portrait,square
  }

  struct PressCoverage : Codable, Equatable, Hashable {
    let source: String
    let quote: String
    let url: URL
    let date: Date
  }
  
  
  let description: String
  let title: String
  let isOpenSource: Bool
  let logo : URL
  let style : ScreenshotStyle
  let screenshots : [URL]
  let pressCoverage: [PressCoverage]
  let platforms: [String]
  let technologies: [String]

  let productURL : URL
  let githubURL : URL?
  var itemContent: [Node<HTML.BodyContext>] {
    [
      .if(self.isOpenSource, .class("open-source"), else: nil),
      .section(
        //      <li>
        //              <section>
        //                <header>
        //                  <a href="#">
        //                    <img src="http://placeimg.com/200/200/tech/services-hero">
        //                    <h3>Portrait</h3>
        //                  </a>
        //                  <ol class="links">
        //                    <li><a href="#">Product Page</a></li>
        //                    <li><a href="#"><i class="flaticon-github"></i> GitHub</a></li>
        //                  </ol>
        //                  <ol class="platforms">
        //                    <li>
        //                      iPhone
        //                    </li>
        //                    <li>
        //                      iPad
        //                    </li>
        //                    <li>
        //                      Apple Watch
        //                    </li>
        //                    <li>
        //                      Web
        //                    </li>
        //                    <li>
        //                      Mac
        //                    </li>
        //                  </ol>
        //                </header>
        .header(
          .a(
            .href(self.productURL),
            .img(.src(self.logo)),
            .h3(.text(self.title))
          ),
          .ol(
            .class("links")
//            .forEach(self.links, { pair in
//            .li(
//              .a(
//                .href(pair.value),
//                .target(.blank)
//                //.icon(for: pair.key)
//              )
//            )
//            })
          ),
          .ol(
            .class("platforms"),
            .forEach(self.platforms, { platform in
              .li(.text(platform))
            })
          )
        ),
        .main(.p(.text(self.description)))
)
      ]
  }
  
  init(item: Item<BrightDigitSite>) throws {
    self.title = item.title
    self.description = item.description
    self.isOpenSource = item.metadata.isOpenSource ?? false
    
    guard let logo = item.metadata.logo.flatMap(URL.init(string:)) else {
      throw PiError.missingField(MissingFields.ProductField.logo, item)
    }
    
    guard let productURL = item.metadata.product.flatMap(URL.init(string:)) else {
      throw PiError.missingField(MissingFields.ProductField.productURL, item)
    }
    
    self.logo = logo
    
    self.productURL = productURL
    
    self.githubURL = item.metadata.github.flatMap(URL.init(string:))
    
    self.style = item.metadata.style ?? .default
    self.screenshots = try item.metadata.screenshots?.map({ string in
      guard let url = URL(string: string) else {
        throw PiError.invalidURLValue(string)
      }
      return url
    }) ?? []
    
    self.pressCoverage = item.metadata.pressCoverage ?? []
    
    self.platforms = item.metadata.platforms ?? []
    
    self.technologies = item.metadata.technologies ?? []
  }
}
