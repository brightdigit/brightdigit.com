/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Publish
import XCTest

internal final class WebsiteTests: PublishTestCase {
  // Assigned in `setUp()` before every test, following the standard XCTest idiom.
  // swift-format-ignore: NeverUseImplicitlyUnwrappedOptionals
  // swiftlint:disable:next implicitly_unwrapped_optional
  private var website: WebsiteStub.WithoutItemMetadata!

  override internal func setUp() {
    super.setUp()
    website = .init()
  }

  internal func testDefaultTagListPath() {
    XCTAssertEqual(website.tagListPath, "tags")
  }

  internal func testCustomTagListPath() {
    website.tagHTMLConfig = TagHTMLConfiguration(basePath: "custom")
    XCTAssertEqual(website.tagListPath, "custom")
  }

  internal func testPathForSectionID() {
    XCTAssertEqual(website.path(for: .one), "one")
  }

  internal func testPathForSectionIDWithRawValue() {
    XCTAssertEqual(website.path(for: .customRawValue), "custom-raw-value")
  }

  internal func testDefaultPathForTag() {
    let tag = Tag("some tag")
    XCTAssertEqual(website.path(for: tag), "tags/some-tag")
  }

  internal func testCustomPathForTag() {
    website.tagHTMLConfig = TagHTMLConfiguration(basePath: "custom")
    let tag = Tag("some tag")
    XCTAssertEqual(website.path(for: tag), "custom/some-tag")
  }

  internal func testDefaultURLForTag() {
    XCTAssertEqual(
      website.url(for: Tag("some tag")),
      URL(string: "https://swiftbysundell.com/tags/some-tag")
    )
  }

  internal func testCustomURLForTag() {
    website.tagHTMLConfig = TagHTMLConfiguration(basePath: "custom")

    XCTAssertEqual(
      website.url(for: Tag("some tag")),
      URL(string: "https://swiftbysundell.com/custom/some-tag")
    )
  }

  internal func testURLForRelativePath() {
    XCTAssertEqual(
      website.url(for: Path("a/path")),
      URL(string: "https://swiftbysundell.com/a/path")
    )
  }

  internal func testURLForAbsolutePath() {
    XCTAssertEqual(
      website.url(for: Path("/a/path")),
      URL(string: "https://swiftbysundell.com/a/path")
    )
  }

  internal func testURLForLocation() {
    let page = Page(path: "mypage", content: Content())

    XCTAssertEqual(
      website.url(for: page),
      URL(string: "https://swiftbysundell.com/mypage")
    )
  }
}
