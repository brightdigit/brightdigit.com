@testable import Contribute
import XCTest

internal final class FilteredHTMLMarkdownExtractorTests: XCTestCase {
  internal func testSuccessfulHtmlExtract() throws {
    let sut = FilteredHTMLMarkdownExtractor<MockSource>()

    var isCalled: Bool = false
    _ = try sut.markdown(from: .init()) { value in
      isCalled = true
      return value
    }

    XCTAssertNotNil(isCalled)
    XCTAssertTrue(isCalled)
  }

  internal func testFailedHtmlExtract() throws {
    let sut = FilteredHTMLMarkdownExtractor<MockSource>()

    XCTAssertThrowsError(
      try sut.markdown(from: .init()) { _ in
        throw TestError.htmlExtract
      }
    ) { actualError in
      guard
        let actualError = actualError as? TestError,
        actualError == .htmlExtract else {
        XCTFail("Expected failed html extract")
        return
      }
    }
  }
}
