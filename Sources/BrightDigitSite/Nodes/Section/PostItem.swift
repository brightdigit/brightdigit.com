import Foundation
import Plot
import Publish
import PublishType

struct PostItem<PostableType: Postable>: SectionItem {
  typealias WebsiteType = BrightDigitSite
  static var sectionH1: String? {
    PostableType.sectionH1
  }

  static var sectionDescription: String {
    PostableType.sectionDescription
  }

  static var sectionTitle: String {
    PostableType.sectionTitle
  }

  let slug: String
  let description: String
  let featuredImageURL: URL
  let title: String
  let publishedDate: Date
  let source: Item<BrightDigitSite>
  let site: BrightDigitSite
  let subscriptionCTA: String?

  let isFeatured: Bool

  var pageTitle: String {
    title
  }

  var pageBodyID: String? {
    nil
  }

  var absoluteURL: URL {
    source.absoluteURL(forSite: site)
  }

  var pageMainContent: [Node<HTML.BodyContext>] {
    [
      pageHeader,
      .main(.contentBody(source.body)),
      pageFooter
    ]
  }

  var redirectURL: URL? {
    nil
  }

  init(item: Item<BrightDigitSite>, site: BrightDigitSite) throws {
    source = item
    self.site = site
    let featuredImageURL = item.featuredImageURL
    let isFeatured = item.metadata.featured ?? false

    subscriptionCTA = item.metadata.subscriptionCTA
    slug = item.path.string
    title = item.title
    description = item.description
    self.featuredImageURL = featuredImageURL
    publishedDate = item.metadata.date
    self.isFeatured = isFeatured
  }
}
