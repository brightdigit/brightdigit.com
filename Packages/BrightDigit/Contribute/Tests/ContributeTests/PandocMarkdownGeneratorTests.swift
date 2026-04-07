@testable import Contribute
import XCTest

internal final class PandocMarkdownGeneratorTests: XCTestCase {
  internal func testSuccessfulMarkdownGenerate() throws {
    var isCalled: Bool = false
    let sut = PandocMarkdownGenerator { _, _ in
      isCalled = true
      return "result"
    }

    _ = try sut.markdown(fromHTML: "<html />")

    XCTAssertTrue(isCalled)
  }

  internal func testFailedMarkdownGenerate() throws {
    let sut = PandocMarkdownGenerator { _, _ in
      throw TestError.markdownGenerate
    }

    XCTAssertThrowsError(try sut.markdown(fromHTML: "<html />")) { actualError in
      guard
        let actualError = actualError as? TestError,
        actualError == .markdownGenerate else {
        XCTFail("Expected failed markdown generate")
        return
      }
    }
  }
}
