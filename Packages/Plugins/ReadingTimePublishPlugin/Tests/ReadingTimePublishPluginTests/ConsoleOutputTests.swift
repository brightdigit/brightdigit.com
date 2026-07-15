import Plot
import Publish
@testable import ReadingTimePublishPlugin
import Synchronization
import XCTest

final class ConsoleOutputTests: XCTestCase {
    // Reference box so the @Sendable output hook and the test body share one
    // storage location (Mutex is non-copyable and can't be captured directly).
    private final class Captured: Sendable {
        let value = Mutex<String?>(nil)
    }

    private let captured = Captured()

    override func setUp() {
        super.setUp()

        captured.value.withLock { $0 = nil }

        let captured = self.captured
        output.withLock { $0 = { string, _ in captured.value.withLock { $0 = string } } }
    }

    func testItemWithoutMetadata() {
        let item: Item<Web> = .mock

        let metadata = item.readingTime
        XCTAssertEqual(metadata.words, 0)
        XCTAssertEqual(metadata.minutes, 0)
        XCTAssertEqual(
            captured.value.withLock { $0 },
            #"Item "Fake" doesn't have ReadingTimeMetadata. Check that the ReadingTime plugin is installed after the creation of this item."#
        )
    }
}

private extension Item where Site == Web {
    static let mock = Item<Web>(
        path: Path("/none"),
        sectionID: Web.SectionID.test,
        metadata: Web.ItemMetadata(),
        tags: [],
        content: Content(title: "Fake", description: "None", body: .init(html: ""), date: Date(), lastModified: Date(), imagePath: nil, audio: nil, video: nil)
    )
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
