import XCTest

@testable import ReadingTimePublishPlugin

internal final class ReadingTimeTests: XCTestCase {
  internal func testShortText() {
    ReadingTimeFixtures.assertReadingTime(
      "one",
      words: 1,
      minutes: 0,
      timeMinutes: 0.005
    )
    ReadingTimeFixtures.assertReadingTime(
      "this has 4 words",
      words: 4,
      minutes: 0,
      timeMinutes: 0.02
    )
  }

  internal func testLongText() {
    ReadingTimeFixtures.assertReadingTime(
      ReadingTimeFixtures.loremIpsum,
      words: 1_000,
      minutes: 5,
      timeMinutes: 5
    )
  }

  internal func testEmptyText() {
    ReadingTimeFixtures.assertReadingTime(
      "",
      words: 0,
      minutes: 0,
      timeMinutes: 0
    )
    ReadingTimeFixtures.assertReadingTime(
      " ",
      words: 0,
      minutes: 0,
      timeMinutes: 0
    )
    ReadingTimeFixtures.assertReadingTime(
      """


      """,
      words: 0,
      minutes: 0,
      timeMinutes: 0
    )
    ReadingTimeFixtures.assertReadingTime(
      " . ",
      words: 0,
      minutes: 0,
      timeMinutes: 0
    )
  }

  internal func testMultipleSpaces() {
    ReadingTimeFixtures.assertReadingTime(
      "     leading spaces",
      words: 2,
      minutes: 0,
      timeMinutes: 0.01
    )
    ReadingTimeFixtures.assertReadingTime(
      "trailing spaces     ",
      words: 2,
      minutes: 0,
      timeMinutes: 0.01
    )
    ReadingTimeFixtures.assertReadingTime(
      "multiple       spaces",
      words: 2,
      minutes: 0,
      timeMinutes: 0.01
    )
  }

  internal func testPunctuation() {
    ReadingTimeFixtures.assertReadingTime(
      "this has 4.words",
      words: 4,
      minutes: 0,
      timeMinutes: 0.02
    )
    ReadingTimeFixtures.skipAssertReadingTime(
      "this has 4.0 words",
      words: 4,
      minutes: 1,
      timeMinutes: 0.02
    )
    ReadingTimeFixtures.skipAssertReadingTime(
      "this hasn't 5 words",
      words: 4,
      minutes: 1,
      timeMinutes: 0.02
    )
  }

  internal func testHTMLTags() {
    ReadingTimeFixtures.assertReadingTime(
      "<p>html with <b>four</b> words</p>",
      words: 4,
      minutes: 0,
      timeMinutes: 0.02
    )
    ReadingTimeFixtures.assertReadingTime(
      "<h1>Header should</h1><p>not merge words</p>",
      words: 5,
      minutes: 0,
      timeMinutes: 0.025
    )
  }
}
