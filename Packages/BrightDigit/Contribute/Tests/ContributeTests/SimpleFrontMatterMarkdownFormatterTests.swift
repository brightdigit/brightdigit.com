@testable import Contribute
import XCTest

internal final class SimpleFrontMatterMarkdownFormatterTests: XCTestCase {
  private let formatter: SimpleFrontMatterMarkdownFormatter = .simple

  internal func testFormatting() {
    let sut = SimpleFrontMatterMarkdownFormatter()

    let frontMatter = "title: 2018 - My Year in Review"
    let markdown = """
    ## My Goals for 2018

    As I said I removed many activities from my life mostly...
    """

    assert(sut: sut, frontMatterText: frontMatter, markdownText: markdown)
  }

  internal func testEmptyInputs() {
    let sut = SimpleFrontMatterMarkdownFormatter()

    assert(sut: sut, frontMatterText: "", markdownText: "")
  }

  private func assert(
    sut: SimpleFrontMatterMarkdownFormatter,
    frontMatterText: String,
    markdownText: String
  ) {
    let actualFormattedString = sut.format(
      frontMatterText: frontMatterText,
      withMarkdown: markdownText
    )

    let expectedFormattedString = ["---", frontMatterText, "---", markdownText]
      .joined(separator: "\n")

    XCTAssertEqual(actualFormattedString, expectedFormattedString)
  }
}
