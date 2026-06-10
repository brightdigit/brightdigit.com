import Ink
import Publish
import XCTest
@testable import YoutubePublishPlugin

internal final class YoutubePublishPluginTests: XCTestCase {
  internal static var allTests = [
    ("testValidYoutubeBlockQuote", testValidYoutubeBlockQuote),
    ("testInvalidBlockQuotePrefix", testInvalidBlockQuotePrefix)
  ]

  private var parser: MarkdownParser = .init(modifiers: [
    .youtubeBlockQuote(using: DefaultYoutubeRenderer())
  ])

  internal func testValidYoutubeBlockQuote() throws {
    let videoID = "0HHAo1mLgxY"
    let link = "https://www.youtube.com/watch?v=\(videoID)"

    let youtubeBlockQuote = "> youtube \(link)"

    let html = parser.html(from: youtubeBlockQuote)
    XCTAssertTrue(html.contains("https://www.youtube.com/embed/\(videoID)"))
  }

  internal func testInvalidBlockQuotePrefix() throws {
    let videoID = "0HHAo1mLgxY"
    let link = "https://www.youtube.com/watch?v=\(videoID)"

    let plainBlockQuote = "> youtub \(link)"

    let html = parser.html(from: plainBlockQuote)
    XCTAssertFalse(html.contains("https://www.youtube.com/embed/\(videoID)"))
  }
}
