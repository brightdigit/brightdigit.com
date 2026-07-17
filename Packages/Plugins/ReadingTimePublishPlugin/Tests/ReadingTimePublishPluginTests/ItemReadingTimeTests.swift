import Foundation
import Plot
import Publish
@testable import ReadingTimePublishPlugin
import XCTest

final class ItemReadingTimeTests: XCTestCase {
    func testReadingTimeComputedFromBody() {
        let item = Item<Web>.mock(html: "<p>html with <b>four</b> words</p>")
        let metadata = item.readingTime
        XCTAssertEqual(metadata.words, 4)
        XCTAssertEqual(metadata.minutes, 0)
    }

    func testEmptyBodyIsZero() {
        let item = Item<Web>.mock(html: "")
        let metadata = item.readingTime
        XCTAssertEqual(metadata.words, 0)
        XCTAssertEqual(metadata.minutes, 0)
    }
}

private extension Item where Site == Web {
    static func mock(html: String) -> Item<Web> {
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

private struct Web: Website {
    var url: URL
    var name: String
    var description: String
    var language: Language
    var imagePath: Path?

    enum SectionID: String, WebsiteSectionID {
        case test
    }

    struct ItemMetadata: WebsiteItemMetadata {}
}
