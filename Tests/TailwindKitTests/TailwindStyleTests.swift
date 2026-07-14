//
//  TailwindStyleTests.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

@testable import TailwindKit
import XCTest

// Plot-independent: these assert `.rendered` string equality only; nothing here
// imports Plot.
internal final class TailwindStyleTests: XCTestCase {
  internal func testEmptyRendersEmptyString() {
    XCTAssertEqual(TailwindStyle().rendered, "")
    XCTAssertEqual(TW().rendered, "")
  }

  internal func testConfirmedCanonicalExample() {
    XCTAssertEqual(
      TW.flex.items(.center).gap(4).bg(.blue, ._500).rendered,
      "flex items-center gap-4 bg-blue-500"
    )
  }

  internal func testPlanExample() {
    XCTAssertEqual(
      TW.flex.items(.center).gap(4).rendered,
      "flex items-center gap-4"
    )
  }

  internal func testColorShadeToken() {
    XCTAssertEqual(TW.bg(.blue, ._500).rendered, "bg-blue-500")
    XCTAssertEqual(TW.text(.gray, ._700).rendered, "text-gray-700")
    XCTAssertEqual(TW.borderColor(.slate, ._200).rendered, "border-slate-200")
  }

  internal func testBareUtilitiesAreProperties() {
    XCTAssertEqual(TW.flex.rendered, "flex")
    XCTAssertEqual(TW.grid.rendered, "grid")
    XCTAssertEqual(TW.hidden.rendered, "hidden")
    XCTAssertEqual(TW.italic.underline.rendered, "italic underline")
    XCTAssertEqual(TW.gap.rendered, "gap")
  }

  internal func testSpacingScale() {
    XCTAssertEqual(TW.p(4).rendered, "p-4")
    XCTAssertEqual(TW.px(2.5).rendered, "px-2.5")
    XCTAssertEqual(TW.my(0).mt(8).rendered, "my-0 mt-8")
    XCTAssertEqual(TW.p(.px).rendered, "p-px")
    // A whole-number float drops its trailing ".0".
    XCTAssertEqual(TW.gap(2.0).rendered, "gap-2")
  }

  internal func testSizing() {
    XCTAssertEqual(TW.w(.full).h(.screen).rendered, "w-full h-screen")
    XCTAssertEqual(TW.w(4).rendered, "w-4")
    XCTAssertEqual(TW.h(.auto).rendered, "h-auto")
  }

  internal func testTypography() {
    XCTAssertEqual(TW.text(.lg).font(.medium).rendered, "text-lg font-medium")
    XCTAssertEqual(TW.text(.xl2).rendered, "text-2xl")
    XCTAssertEqual(TW.text(.center).rendered, "text-center")
    XCTAssertEqual(TW.text(.blue, ._500).rendered, "text-blue-500")
  }

  internal func testFlexAndGrid() {
    XCTAssertEqual(
      TW.flex.flexCol.justify(.between).items(.stretch).rendered,
      "flex flex-col justify-between items-stretch"
    )
    XCTAssertEqual(TW.grid.gridCols(3).gap(6).rendered, "grid grid-cols-3 gap-6")
  }

  internal func testBordersAndRadius() {
    XCTAssertEqual(TW.border.rounded.rendered, "border rounded")
    XCTAssertEqual(TW.border(2).rounded(.lg).rendered, "border-2 rounded-lg")
    // `rounded(.base)` collapses to bare `rounded`.
    XCTAssertEqual(TW.rounded(.base).rendered, "rounded")
    XCTAssertEqual(TW.rounded(.full).rendered, "rounded-full")
  }

  internal func testResponsivePrefix() {
    XCTAssertEqual(
      TW.flex.md(.gap(4).items(.center)).rendered,
      "flex md:gap-4 md:items-center"
    )
    XCTAssertEqual(TW.block.lg(.hidden).rendered, "block lg:hidden")
  }

  internal func testStatePrefix() {
    XCTAssertEqual(
      TW.bg(.blue, ._500).hover(.bg(.blue, ._700)).rendered,
      "bg-blue-500 hover:bg-blue-700"
    )
  }

  internal func testStackedPrefixes() {
    XCTAssertEqual(
      TW.md(.hover(.bg(.blue, ._700))).rendered,
      "md:hover:bg-blue-700"
    )
    XCTAssertEqual(
      TW.dark(.text(.gray, ._100)).rendered,
      "dark:text-gray-100"
    )
  }

  internal func testStaticAndInstanceEntryPointsAgree() {
    // Leading-dot static entry vs. explicit-empty instance chain.
    XCTAssertEqual(TailwindStyle.flex.gap(4), TailwindStyle().flex.gap(4))
    XCTAssertEqual(TW.bg(.blue, ._500), TailwindStyle().bg(.blue, ._500))
  }

  internal func testEquatable() {
    XCTAssertEqual(TW.flex.gap(4), TW.flex.gap(4))
    XCTAssertNotEqual(TW.flex.gap(4), TW.flex.gap(2))
  }
}
