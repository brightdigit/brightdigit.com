@testable import Contribute
import XCTest

internal final class MarkdownContentYAMLBuilderTests: XCTestCase {
  internal func testSuccessfulYAMLBuild() throws {
    let exporter = FrontMatterExporterSpy.success
    let extractor = MarkdownExtractorSpy.success

    let sut = MarkdownContentYAMLBuilder(
      frontMatterExporter: exporter,
      markdownExtractor: extractor
    )

    XCTAssertNoThrow(try sut.content(from: .init()) { $0 })
  }

  internal func testFailedFrontMatterExport() throws {
    assertSUT(with: .failure, and: .success, expectedError: .frontMatterExport)
  }

  internal func testFailedMarkdownExtract() throws {
    assertSUT(with: .success, and: .failure, expectedError: .markdownExtract)
  }

  private func assertSUT(
    with frontMatterExporter: FrontMatterExporterSpy,
    and markdownExtractor: MarkdownExtractorSpy,
    expectedError: TestError
  ) {
    let sut = MarkdownContentYAMLBuilder(
      frontMatterExporter: frontMatterExporter,
      markdownExtractor: markdownExtractor
    )

    assertThrowableBlock(expectedError: expectedError) {
      try sut.content(from: .init()) { $0 }
    }
  }
}
