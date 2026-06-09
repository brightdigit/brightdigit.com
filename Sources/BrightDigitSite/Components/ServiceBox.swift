import Plot

internal struct ServiceBox: Component {
  internal let id: String
  internal let bigImage: Image
  internal let smallImage: Image
  internal let title: String
  internal let text: String

  internal var body: Component {
    Element(name: "section") {
      Header {
        bigImage.class("rounded-lg")
      }
      Element(name: "main") {
        Header {
          smallImage
          H2(title)
        }
        Paragraph {
          Text(self.text)
        }
        Footer {
          Link("Contact Us", url: "/contact-us").class("button")
        }
      }
    }.class("service").id(id)
  }
}
