import Plot

extension ListItem {
  init(forPressCoverage pressCoverage: ProductItem.PressCoverage) {
    self.init {
      Link(url: pressCoverage.url) {
        Element(name: "figure") {
          Element(name: "blockquote") {
            Paragraph(Text(pressCoverage.quote))
          }.attribute(named: "cite", value: pressCoverage.url.absoluteString)
          Element(name: "figcaption") {
            Span(pressCoverage.source).class("name")
          }
          Element(name: "cite") {
            Text(PiHTMLFactory.itemFormatter.string(from: pressCoverage.date))
          }
        }
      }.linkTarget(.blank)
    }
  }
  
  init(forProduct product: ProductItem) {
    self.init {
      SectionElement(forProduct: product)
    }
  }
}
