import Foundation
import Publish
import XCTest

@testable import NPMPublishPlugin

internal final class ArgumentTests: XCTestCase {
  internal func testStringArgumentReturnsValueUnchanged() {
    let argument: NPM.Argument = .string("--yes")

    XCTAssertEqual(argument.relativePath(basedOn: [:]), "--yes")
  }

  internal func testStringLiteralInitProducesStringCase() {
    let argument: NPM.Argument = "--flag"

    guard case .string(let value) = argument else {
      return XCTFail("expected .string case")
    }
    XCTAssertEqual(value, "--flag")
  }

  internal func testPathArgumentResolvesAndQuotesMappedValue() {
    let path: OutputPath = .file(.init("output.css"))
    let map: [OutputPath: String] = [path: "build/output.css"]
    let argument: NPM.Argument = .path(path)

    XCTAssertEqual(argument.relativePath(basedOn: map), "\"build/output.css\"")
  }

  internal func testPathArgumentFallsBackToQuotedDefaultWhenMissing() {
    let path: OutputPath = .folder(.init("dist"))
    let argument: NPM.Argument = .path(path)

    XCTAssertEqual(argument.relativePath(basedOn: [:]), "\"\"")
    XCTAssertEqual(
      argument.relativePath(basedOn: [:], withDefaultValue: "fallback"),
      "\"fallback\""
    )
  }
}
