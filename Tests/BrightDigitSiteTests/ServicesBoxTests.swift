@testable import BrightDigitSite
import Plot
import XCTest

internal final class ServicesBoxTests: XCTestCase {
  /// Verifies the TailwindKit integration in ``Services/Box`` renders the
  /// expected `rounded-lg` utility class end-to-end through Plot — i.e. that
  /// `TW.rounded(.lg).rendered` produces the same output the raw string did.
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
