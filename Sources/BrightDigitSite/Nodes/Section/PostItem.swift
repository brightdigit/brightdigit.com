import Foundation
import Plot
import Publish
import PublishType

internal struct PostItem<PostableType: Postable>: SectionItem {
  internal typealias WebsiteType = BrightDigitSite
  internal static var sectionH1: String? {
    PostableType.sectionH1
  }

  internal static var sectionDescription: String {
    PostableType.sectionDescription
  }

  internal static var sectionTitle: String {
    PostableType.sectionTitle
  }

  internal let slug: String
  internal let description: String
  internal let featuredImageURL: URL
  internal let title: String
  internal let publishedDate: Date
  internal let source: Item<BrightDigitSite>
  internal let site: BrightDigitSite
  internal let subscriptionCTA: String?

  internal let isFeatured: Bool

  internal var pageTitle: String {
    title
  }

  internal var pageBodyID: String? {
    nil
  }

  internal var absoluteURL: URL {
    source.absoluteURL(forSite: site)
  }

  internal var pageMainContent: [Node<HTML.BodyContext>] {
    [
      pageHeader,
      .main(.contentBody(source.body)),
      pageFooter,
    ]
  }

  internal var redirectURL: URL? {
    nil
  }

  internal init(item: Item<BrightDigitSite>, site: BrightDigitSite) throws {
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
