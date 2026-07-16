/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot
import XCTest

internal final class ControlFlowTests: XCTestCase {
  internal func testIfCondition() {
    XCTAssertEqual(Node<Any>.if(true, .text("True")).render(), "True")
    XCTAssertEqual(Node<Any>.if(false, .text("True")).render(), "")
  }

  internal func testIfElseCondition() {
    XCTAssertEqual(
      Node<Any>.if(true, .text("If"), else: .text("Else")).render(),
      "If"
    )

    XCTAssertEqual(
      Node<Any>.if(false, .text("If"), else: .text("Else")).render(),
      "Else"
    )
  }

  internal func testUnwrappingOptional() {
    var optional: String? = "Hello"
    XCTAssertEqual(Node<Any>.unwrap(optional, Node.text).render(), "Hello")

    optional = nil
    XCTAssertEqual(Node<Any>.unwrap(optional, Node.text).render(), "")
    XCTAssertEqual(Node<Any>.unwrap(optional, Node.text, else: .text("Is nil")).render(), "Is nil")
  }

  internal func testForEach() {
    let array = ["A", "B", "C"]
    XCTAssertEqual(Node<Any>.forEach(array, Node.text).render(), "ABC")
    XCTAssertEqual(Node<Any>.forEach([], Node.text).render(), "")
  }
}
