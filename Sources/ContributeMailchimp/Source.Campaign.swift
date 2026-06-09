// swift-format-ignore-file
// swiftlint:disable all
import Contribute
import Foundation
import Prch

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public extension Newsletter.Source {
  struct Campaign {
    public init(slug: String, issueNo: Int, campaignID: String, longArchiveURL: URL, featuredImageURL: URL? = nil, title: String, subjectLine: String, previewText: String? = nil, sendTime: Date) {
      self.slug = slug
      self.issueNo = issueNo
      self.campaignID = campaignID
      self.longArchiveURL = longArchiveURL
      self.featuredImageURL = featuredImageURL
      self.title = title
      self.subjectLine = subjectLine
      self.previewText = previewText
      self.sendTime = sendTime
    }

    public let slug: String
    public let issueNo: Int
    public let campaignID: String
    public let longArchiveURL: URL
    public let featuredImageURL: URL?
    public let title: String
    public let subjectLine: String
    public let previewText: String?
    public let sendTime: Date
  }
}
