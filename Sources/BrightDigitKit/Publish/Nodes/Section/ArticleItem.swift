import Foundation
import Plot
import Publish

enum ArticlePostable: Postable {
  static let sectionDescription = "Latest Articles from BrightDigit"
}

typealias ArticleItem = PostItem<ArticlePostable>
