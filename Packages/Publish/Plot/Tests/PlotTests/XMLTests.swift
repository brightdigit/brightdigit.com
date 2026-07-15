/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot
import XCTest

internal final class XMLTests: XCTestCase {
  internal func testEmptyXML() {
    assertEqualXMLContent(XML(), "")
  }

  internal func testSingleElement() {
    let xml = XML(.element(named: "hello", text: "world!"))
    assertEqualXMLContent(xml, "<hello>world!</hello>")
  }

  internal func testSelfClosingElement() {
    let xml = XML(.selfClosedElement(named: "element"))
    assertEqualXMLContent(xml, "<element/>")
  }

  internal func testElementWithAttribute() {
    let xml = XML(
      .element(
        named: "element",
        nodes: [
          .attribute(named: "attribute", value: "value")
        ]
      )
    )

    assertEqualXMLContent(xml, #"<element attribute="value"></element>"#)
  }

  internal func testElementWithChildren() {
    let xml = XML(
      .element(
        named: "parent",
        nodes: [
          .selfClosedElement(named: "a"),
          .selfClosedElement(named: "b"),
        ]
      )
    )

    assertEqualXMLContent(xml, "<parent><a/><b/></parent>")
  }
}
