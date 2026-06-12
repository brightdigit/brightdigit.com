// swift-format-ignore-file
// swiftlint:disable all
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public extension Newsletter {
  struct Source: Sendable {
    init(campaign: Campaign, html: String, markdown: String) {
      slug = campaign.slug
      issueNo = campaign.issueNo
      campaignID = campaign.campaignID
      longArchiveURL = campaign.longArchiveURL
      featuredImageURL = campaign.featuredImageURL
      title = campaign.title
      subjectLine = campaign.subjectLine
      previewText = campaign.previewText?.dequote().fixUnicodeEscape()
      sendTime = campaign.sendTime
      self.html = html
      self.markdown = markdown
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
    public let html: String
    public let markdown: String
  }
}
