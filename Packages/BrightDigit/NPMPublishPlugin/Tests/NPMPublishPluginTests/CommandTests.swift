import Foundation
import XCTest

@testable import NPMPublishPlugin

internal final class CommandTests: XCTestCase {
  internal func testPredefinedCommands() {
    XCTAssertEqual(NPM.Command.ci.string, "ci")
    XCTAssertEqual(NPM.Command.run.string, "run")
  }

  internal func testInitWithString() {
    XCTAssertEqual(NPM.Command("install").string, "install")
  }

  internal func testStringLiteralInit() {
    let command: NPM.Command = "test"

    XCTAssertEqual(command.string, "test")
  }
}
