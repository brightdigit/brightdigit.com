@testable import BrightDigitSite
import XCTest

internal final class StringTests: XCTestCase {
  internal func testFixEmojis() {
    let text =
      // swiftlint:disable:next line_length
      "This week the Epic trial (\\U0001F609 pun intended) against Apple has begun. What does that mean for us small folks getting into the App Store?"
    let actual = text.fixEmojiis()
    let expected =
      // swiftlint:disable:next line_length
      "This week the Epic trial (😉 pun intended) against Apple has begun. What does that mean for us small folks getting into the App Store?"

    XCTAssertEqual(actual, expected)
  }

  internal func testDequoteSingleQuotedUnescapesApostrophes() {
    XCTAssertEqual(
      "'why accessibility doesn''t come for free'".dequote(),
      "why accessibility doesn't come for free"
    )
  }

  internal func testDequoteDoubleQuotedUnescapesQuotes() {
    XCTAssertEqual(
      #""a \"quoted\" word and a \\ backslash""#.dequote(),
      #"a "quoted" word and a \ backslash"#
    )
  }

  internal func testDequoteLeavesUnquotedTextAlone() {
    XCTAssertEqual("doesn''t".dequote(), "doesn''t")
  }
}
