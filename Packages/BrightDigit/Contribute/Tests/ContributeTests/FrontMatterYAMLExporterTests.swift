@testable import Contribute
import XCTest

internal final class FrontMatterYAMLExporterTests: XCTestCase {
  internal func testFrontMatterTranslatedFromSource() throws {
    let translator = FrontMatterTranslatorSpy()
    let sut = FrontMatterYAMLExporter(translator: translator)

    _ = try sut.frontMatterText(from: .init())

    XCTAssertTrue(translator.isCalled)
  }
}
