import Foundation
import Plot
import Publish
import XCTest

@testable import ReadingTimePublishPlugin

internal final class ItemReadingTimeTests: XCTestCase {
  internal func testReadingTimeComputedFromBody() {
    let item = ItemReadingTimeFixtures.mockItem(html: "<p>html with <b>four</b> words</p>")
    let metadata = item.readingTime
    XCTAssertEqual(metadata.words, 4)
    XCTAssertEqual(metadata.minutes, 0)
  }

  internal func testEmptyBodyIsZero() {
    let item = ItemReadingTimeFixtures.mockItem(html: "")
    let metadata = item.readingTime
    XCTAssertEqual(metadata.words, 0)
    XCTAssertEqual(metadata.minutes, 0)
  }
}
