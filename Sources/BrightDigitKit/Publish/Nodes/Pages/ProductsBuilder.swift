import Foundation
import Plot
import Publish

struct ProductsBuilder: PageBuilder {
  let description: String = "BrightDigit has built a selection of apps and open-source libraries in Swift."

  var imagePath: Path = "livestream/Heartwitch-BOTW-HCG.png"

  internal init(products: [Product] = Product.all) {
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

  var bodyClasses: [String] { [] }
}
