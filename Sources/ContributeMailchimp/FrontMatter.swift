import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
extension Newsletter {
  /// The YAML front matter emitted for a newsletter issue.
  public struct FrontMatter: Codable {
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
