import XCTest

@testable import Contribute

internal final class HTMLtoMarkdownTests: XCTestCase {
  internal func testSuccessfulMarkdownGenerate() throws {
    let sut = HTMLtoMarkdown { _ in "#markdown" }

    let actualMarkdown = try sut.markdown(fromHTML: "<html />")

    XCTAssertEqual(actualMarkdown, "#markdown")
  }

  internal func testFailedMarkdownGenerate() throws {
    let sut = HTMLtoMarkdown { _ in
      throw TestError.markdownGenerate
    }

    XCTAssertThrowsError(try sut.markdown(fromHTML: "")) { actualError in
      guard
        let actualError = actualError as? TestError,
        actualError == .markdownGenerate
      else {
        XCTFail("Expected failed markdown generate")
        return
      }
    }
  }
}
