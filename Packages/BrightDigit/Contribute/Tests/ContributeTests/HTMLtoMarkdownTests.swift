@testable import Contribute
import XCTest

internal final class HTMLtoMarkdownTests: XCTestCase {
  private enum MarkdownGeneratorError: Error {
    case invalidHtmlString
  }

  internal func testSuccessfulMarkdownGenerate() throws {
    var isCalled: Bool = false
    let sut = HTMLtoMarkdown { _ in
      isCalled = true
      return "#markdown"
    }

    _ = try sut.markdown(fromHTML: "<html />")

    XCTAssertTrue(isCalled)
  }

  internal func testFailedMarkdownGenerate() throws {
    let sut = HTMLtoMarkdown { _ in
      throw TestError.markdownGenerate
    }

    XCTAssertThrowsError(try sut.markdown(fromHTML: "")) { actualError in
      guard
        let actualError = actualError as? TestError,
        actualError == .markdownGenerate else {
        XCTFail("Expected failed markdown generate")
        return
      }
    }
  }
}
