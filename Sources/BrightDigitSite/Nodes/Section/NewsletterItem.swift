import Foundation
import Plot
import Publish
import PublishType

struct NewsletterItem: SectionItem {
  typealias WebsiteType = BrightDigitSite

  static let sectionH1: String? = nil
  static let sectionTitle: String = "Newsletters"
  static let sectionDescription: String = "Subscribe to the BrightDigit newsletter now and get  helpful tips and advice right to your inbox!"

  let description: String
  let issueNo: Int
  let featuredImageURL: URL
  let archiveURL: URL
  let title: String
  let publishedDate: Date
  let source: Item<BrightDigitSite>

  let isFeatured: Bool

  var pageTitle: String {
    title
  }

  var pageBodyID: String? {
    nil
  }

  var pageMainContent: [Node<HTML.BodyContext>] {
    [.contentBody(source.body)]
  }

  var redirectURL: URL? {
    archiveURL
  }

  init(item: Item<BrightDigitSite>, site _: BrightDigitSite) throws {
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
