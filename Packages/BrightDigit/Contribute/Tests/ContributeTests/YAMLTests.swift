import XCTest

@testable import Contribute

internal final class YAMLTests: XCTestCase {
  internal func testValidDateFormat() {
    XCTAssertEqual(
      YAML.dateFormatter.dateFormat,
      "yyyy-MM-dd HH:mm"
    )
  }

  internal func testValidTimezone() {
    XCTAssertEqual(
      YAML.dateFormatter.timeZone,
      TimeZone.current
    )
  }
}
