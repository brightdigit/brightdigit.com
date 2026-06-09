import Foundation
import Plot
import Publish

internal enum ArticlePostable: Postable {
  internal static let sectionH1 = "Latest Articles"

  internal static let sectionTitle =
    "Articles – Practical Advice and Tips on App Development and all things Apple"
  internal static let sectionDescription =
    "Check out our articles for advice and learn about the latest on Swift App Development, App project management, and the latest developments in the world of Apple."

  internal static let twitterSource = "brightdigit"
}

internal typealias ArticleItem = PostItem<ArticlePostable>

extension Postable {
  internal static var linkedInSource: String {
    "brightdigit.com"
  }
}
