import Plot
import XCTest

@testable import BrightDigitSite

internal final class ServicesBoxTests: XCTestCase {
  /// Verifies that ``Services/Box`` renders the TailwindKit `rounded-lg` utility.
  ///
  /// This exercises `TW.rounded(.lg).rendered` end-to-end through Plot.
  internal func testBigImageRendersRoundedLgClass() {
    let box = Services.Box(
      id: "example",
      bigImage: Image("big.png"),
      smallImage: Image("small.png"),
      title: "Example",
      text: "Example text."
    )

    let html = box.render()

    XCTAssertTrue(
      html.contains("class=\"rounded-lg\""),
      "Expected the big image to render class=\"rounded-lg\"; got: \(html)"
    )
  }
}
