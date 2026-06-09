import Plot

internal struct SectionElement: Component {
  internal let content: ContentProvider
  internal var body: Component {
    Element(name: "section", content: content)
  }

  internal init(
    @ComponentBuilder content: @escaping ContentProvider
  ) {
    self.content = content
  }
}

extension SectionElement {
  // swiftlint:disable:next function_body_length
  internal init(forProduct product: ProductItem) {
    self.init {
      Header {
        Link(url: product.productURL) {
          Image(url: product.logo, description: "\(product.title) logo")
            .class(product.clipLogo ? "" : "no-clip")
          H2 {
            Text(product.title)
          }
        }.linkTarget(.blank)
        List {
          ListItem {
            Link("Product Page", url: product.productURL)
            if let appStoreURL = product.appStoreURL {
              ListItem {
                Link(url: appStoreURL) {
                  Icon(className: "flaticon-app")
                  Text("AppStore")
                }.linkTarget(.blank)
              }
            }
            if let githubURL = product.githubURL {
              ListItem {
                Link(url: githubURL) {
                  Icon(className: "flaticon-github")
                  Text("GitHub")
                }.linkTarget(.blank)
              }
            }
            if let pressKitURL = product.pressKitURL {
              ListItem {
                Link(url: pressKitURL) {
                  Icon(className: "flaticon-press-release")
                  Text("Press Kit")
                }.linkTarget(.blank)
              }
            }
          }
        }.class("links")

        List(product.platforms) { platform in
          ListItem(platform)
        }.class("platforms")
      }
      Element(name: "main") {
        product.source.body.node
        List(product.screenshots) { screenshotURL in
          ListItem {
            Image(screenshotURL)
          }
        }.class("screenshots \(product.style.rawValue)")
        //          List(product.pressCoverage, content: ListItem.init(forPressCoverage:)).class("press-coverage")
      }
      Footer {
        SectionElement {
          H4(Text("Technologies"))
          List(product.technologies) { tech in
            ListItem(Text(tech))
          }
        }
      }
    }
  }
}
