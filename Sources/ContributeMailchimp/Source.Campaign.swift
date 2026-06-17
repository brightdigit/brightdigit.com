import Contribute
import Foundation

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
extension Newsletter.Source {
  /// The metadata extracted from a Mailchimp campaign that identifies a
  /// newsletter issue.
  public struct Campaign: Sendable {
    public let slug: String
    public let issueNo: Int
    public let campaignID: String
    public let longArchiveURL: URL
    public let featuredImageURL: URL?
    public let title: String
    public let subjectLine: String
    public let previewText: String?
    public let sendTime: Date

    public init(
      slug: String,
      issueNo: Int,
      campaignID: String,
      longArchiveURL: URL,
      featuredImageURL: URL? = nil,
      title: String,
      subjectLine: String,
      previewText: String? = nil,
      sendTime: Date
    ) {
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
  }
}
