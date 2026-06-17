import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

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
