/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Publish
import XCTest

extension ContentMutationTests {
  internal func testMutatingPage() throws {
    let site = try publishWebsite(using: [
      .addPage(.stub(withPath: "a")),
      .mutatePage(
        at: "a",
        using: { page in
          page.title = "A: Mutated"
        }
      ),
    ])

    XCTAssertEqual(site.pages["a"]?.title, "A: Mutated")
  }

  internal func testMutatingPageByChangingPath() throws {
    let site = try publishWebsite(using: [
      .addPage(.stub(withPath: "a")),
      .mutatePage(
        at: "a",
        using: { page in
          page.path = "b"
        }
      ),
    ])

    XCTAssertNil(site.pages["a"])
    XCTAssertNotNil(site.pages["b"])
  }

  internal func testMutatingAllPagesMatchingPredicate() throws {
    let site = try publishWebsite(using: [
      .addPages(in: [
        .stub(withPath: "a"),
        .stub(withPath: "b"),
      ]),
      .mutateAllPages(matching: \.path == "a") { page in
        page.title = "A: Mutated"
      },
    ])

    XCTAssertEqual(site.pages["a"]?.title, "A: Mutated")
    XCTAssertEqual(site.pages["b"]?.title, "")
  }
}
