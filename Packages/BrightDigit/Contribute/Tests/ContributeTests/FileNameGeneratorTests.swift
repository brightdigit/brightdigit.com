import XCTest

@testable import Contribute

internal final class FileNameGeneratorTests: XCTestCase {
  internal func testFileNameGenerate() {
    var isCalled: Bool = false
    let sut = FileNameGenerator<MockSource> { _ in
      isCalled = true
      return "result"
    }

    _ = sut.destinationURL(from: .init(), atContentPathURL: .temporaryDirURL)

    XCTAssertTrue(isCalled)
  }
}
