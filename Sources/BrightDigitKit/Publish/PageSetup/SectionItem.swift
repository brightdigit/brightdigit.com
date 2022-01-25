import Foundation
import Plot
import Publish

protocol PostItem: SectionItem {
  var isFeatured: Bool { get }
  var featuredItemContent: [Node<HTML.BodyContext>] { get }
}

protocol SectionItem {
  var itemContent: [Node<HTML.BodyContext>] { get }
  init(item: Item<BrightDigitSite>) throws
}

extension SectionItem {
  static func content(forSection section: Section<BrightDigitSite>, withContext _: PublishingContext<BrightDigitSite>) throws -> PageContent {
    let children = try section.items.map(Self.init(item:))
    let builder = SectionBuilder(section: section, children: children, featuredItem: nil)
    return SectionContent(builder: builder)
  }
}

extension PostItem {
  static func content(forSection section: Section<BrightDigitSite>, withContext _: PublishingContext<BrightDigitSite>) throws -> PageContent {
    let allChildren = try section.items.map(Self.init(item:))

    let featuredIndex = allChildren.firstIndex(where: { $0.isFeatured }) ?? allChildren.startIndex
    var children = allChildren
    children.remove(at: featuredIndex)
    let builder = SectionBuilder(section: section, children: children, featuredItem: allChildren[featuredIndex])
    return SectionContent(builder: builder)
  }
}
