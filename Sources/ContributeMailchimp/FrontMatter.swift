// swift-format-ignore-file
// swiftlint:disable all
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public extension Newsletter {
  struct FrontMatter: Codable {
    let issueNo: Int
    let campaignID: String
    let featuredImage: URL?
    let longArchiveURL: URL
    let newsletterTitle: String
    let title: String
    let date: String
    let description: String?
  }
}
