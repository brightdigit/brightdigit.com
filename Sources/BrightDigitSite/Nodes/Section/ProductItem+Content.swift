import Foundation
import Plot
import Publish
import PublishType

extension ProductItem {
  var featuredItemContent: Plot.Node<Plot.HTML.BodyContext> {
    SectionElement{
      List{
        ListItem(forProduct: self)
      }
    }.environmentValue(.ordered, key: .listStyle).convertToNode()
  }

  var sectionItemContent: [Plot.Node<Plot.HTML.BodyContext>] {
    [SectionElement(forProduct: self).environmentValue(.ordered, key: .listStyle).convertToNode()]
  }
}
