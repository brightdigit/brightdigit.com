/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot
import XCTest

internal final class DocumentTests: XCTestCase {
  internal func testEmptyDocument() {
    let document = Document<FormatStub>.custom()
    XCTAssertEqual(document.render(), "")
  }

  internal func testEmptyIndentedDocument() {
    let document = Document<FormatStub>.custom()
    XCTAssertEqual(document.render(indentedBy: .spaces(4)), "")
  }

  // swiftlint:disable:next function_body_length
  internal func testIndentationWithSpaces() {
    let document = Document.custom(
      withFormat: FormatStub.self,
      elements: [
        .named(
          "one",
          nodes: [
            .element(
              named: "two",
              nodes: [
                .selfClosedElement(named: "three")
              ]
            ),
            .text("four "),
            .component(Text("five")),
            .component(
              Element.named(
                "six",
                nodes: [
                  .text("seven")
                ]
              )
            ),
            .element(
              named: "eight",
              nodes: [
                .text("nine")
              ]
            ),
          ]
        ),
        .selfClosed(
          named: "ten",
          attributes: [
            Attribute(name: "key", value: "value")
          ]
        ),
      ]
    )

    // The expected value is deliberately indented four spaces per level to
    // exercise `.spaces(4)` rendering, which is not a multiple-of-two step.
    // swiftlint:disable indentation_width
    XCTAssertEqual(
      document.render(indentedBy: .spaces(4)),
      """
      <one>
          <two>
              <three/>
          </two>four five
          <six>seven</six>
          <eight>nine</eight>
      </one>
      <ten key="value"/>
      """
    )
    // swiftlint:enable indentation_width
  }

  internal func testIndentationWithTabs() {
    let document = Document.custom(
      withFormat: FormatStub.self,
      elements: [
        .named(
          "one",
          nodes: [
            .element(
              named: "two",
              nodes: [
                .selfClosedElement(named: "three")
              ]
            ),
            .element(named: "four"),
          ]
        ),
        .selfClosed(
          named: "five",
          attributes: [
            Attribute(name: "key", value: "value")
          ]
        ),
      ]
    )

    XCTAssertEqual(
      document.render(indentedBy: .tabs(1)),
      """
      <one>
      \t<two>
      \t\t<three/>
      \t</two>
      \t<four></four>
      </one>
      <five key="value"/>
      """
    )
  }
}

extension DocumentTests {
  fileprivate struct FormatStub: DocumentFormat {
    enum RootContext {}
  }
}
