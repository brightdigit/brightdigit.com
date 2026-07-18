import Foundation
import Plot
import Publish

@testable import ReadingTimePublishPlugin

internal enum ItemReadingTimeFixtures {
  internal struct Web: Website {
    internal enum SectionID: String, WebsiteSectionID {
      case test
    }

    internal struct ItemMetadata: WebsiteItemMetadata {}

    internal var url: URL
    internal var name: String
    internal var description: String
    internal var language: Language
    internal var imagePath: Path?
  }

  internal static func mockItem(html: String) -> Item<Web> {
    Item<Web>(
      path: Path("/none"),
      sectionID: Web.SectionID.test,
      metadata: Web.ItemMetadata(),
      tags: [],
      content: Content(
        title: "Fake",
        description: "None",
        body: .init(html: html),
        date: Date(),
        lastModified: Date(),
        imagePath: nil,
        audio: nil,
        video: nil
      )
    )
  }
}
