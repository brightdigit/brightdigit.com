import Foundation
import XCTest

@testable import NPMPublishPlugin

internal final class NPMInvocationErrorTests: XCTestCase {
  internal func testDescriptionFormatsCommandStatusAndStandardError() {
    let error = NPMInvocationError(
      command: "cd /tmp && npm ci",
      terminationStatus: .exited(1),
      standardError: "boom"
    )

    XCTAssertEqual(
      error.description,
      "npm command failed (\(error.terminationStatus)): cd /tmp && npm ci\nboom"
    )
  }
}
