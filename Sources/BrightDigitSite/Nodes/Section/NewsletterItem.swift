import Foundation
import Plot
import Publish
import PublishType

internal struct NewsletterItem: SectionItem {
  internal typealias WebsiteType = BrightDigitSite

  internal static let sectionH1: String? = nil
  internal static let sectionTitle: String = "Newsletters"
  internal static let sectionDescription: String =
    "Subscribe to the BrightDigit newsletter now and get  helpful tips and advice right to your inbox!"

  internal let description: String
  internal let issueNo: Int
  internal let featuredImageURL: URL
  internal let archiveURL: URL
  internal let title: String
  internal let publishedDate: Date
  internal let source: Item<BrightDigitSite>

  internal let isFeatured: Bool

  internal var pageTitle: String {
    title
  }

  internal var pageBodyID: String? {
    nil
  }

  internal var pageMainContent: [Node<HTML.BodyContext>] {
    [.contentBody(source.body)]
  }

  internal var redirectURL: URL? {
    archiveURL
  }

  internal init(item: Item<BrightDigitSite>, site _: BrightDigitSite) throws {
    source = item
    let featuredImageURL = item.featuredImageURL
    let archiveURL = item.metadata.longArchiveURL.flatMap(URL.init(string:))
    let isFeatured = item.metadata.featured ?? false
    let issueNo = item.metadata.issueNo.flatMap(Int.init)

    guard let archiveURL = archiveURL else {
      throw PublishTypeError.missingField(MissingFields.NewsletterField.archiveURL, item)
    }

    guard let issueNo = issueNo else {
      throw PublishTypeError.missingField(MissingFields.NewsletterField.issueNo, item)
    }

    title = item.title
    description = item.description
    self.featuredImageURL = featuredImageURL
    publishedDate = item.metadata.date
    self.issueNo = issueNo
    self.archiveURL = archiveURL
    self.isFeatured = isFeatured
  }
}
