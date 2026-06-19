import Foundation
import XCTest

@testable import NPMPublishPlugin

internal final class URLRelativePathTests: XCTestCase {
  internal func testNestedChildRelativeToAncestor() {
    let base = URL(fileURLWithPath: "/a/b", isDirectory: true)
    let dest = URL(fileURLWithPath: "/a/b/c/d", isDirectory: true)

    XCTAssertEqual(dest.relativePath(from: base), "c/d")
  }

  internal func testSiblingPathsClimbWithDotDot() {
    let base = URL(fileURLWithPath: "/a/b/c", isDirectory: true)
    let dest = URL(fileURLWithPath: "/a/b/d", isDirectory: true)

    XCTAssertEqual(dest.relativePath(from: base), "../d")
  }

  internal func testIdenticalURLsReturnEmptyString() {
    let url = URL(fileURLWithPath: "/a/b/c", isDirectory: true)

    XCTAssertEqual(url.relativePath(from: url), "")
  }

  internal func testNonFileURLReturnsNil() throws {
    let base = URL(fileURLWithPath: "/a/b", isDirectory: true)
    let remote = try XCTUnwrap(URL(string: "https://example.com/a/b"))

    XCTAssertNil(remote.relativePath(from: base))
    XCTAssertNil(base.relativePath(from: remote))
  }
}
