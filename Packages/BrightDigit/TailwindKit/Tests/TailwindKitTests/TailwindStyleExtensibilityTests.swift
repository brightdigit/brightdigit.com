//
//  TailwindStyleExtensibilityTests.swift
//  TailwindKit
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

import Testing

@testable import TailwindKit

/// Proves the SwiftUI-style extensible token pattern: a consumer can define a
/// custom theme-scale value (a color family, size class, radius, …) and use it
/// through the fluent surface, alongside the built-in leading-dot members.
/// Plot-independent: asserts `.rendered` string equality only.
@Suite internal struct TailwindStyleExtensibilityTests {
  /// A single fixture conforming to every extensible token protocol under test —
  /// a stand-in for the custom `@theme` values a downstream module would define.
  /// One `token` string drives whichever family it's passed as.
  private struct Custom: TailwindStyle.Color, TailwindStyle.TextSize,
    TailwindStyle.Radius
  {
    let token: String
  }

  @Test internal func customColorRendersWithBuiltInShade() {
    let brand = Custom(token: "brand")
    #expect(TW.bg(brand, .s500).rendered == "bg-brand-500")
    #expect(TW.text(brand, .s700).rendered == "text-brand-700")
    #expect(TW.borderColor(brand, .s200).rendered == "border-brand-200")
  }

  @Test internal func customColorComposesWithBuiltInsAndVariants() {
    let brand = Custom(token: "brand")
    #expect(TW.flex.bg(brand, .s500).rendered == "flex bg-brand-500")
    #expect(TW.md(.bg(brand, .s500)).rendered == "md:bg-brand-500")
    // Built-in and custom colors interoperate in one chain.
    #expect(TW.bg(.blue, .s500).text(brand, .s50).rendered == "bg-blue-500 text-brand-50")
  }

  @Test internal func arbitraryColorViaCustomConformance() {
    // The v4 arbitrary-value escape, supplied by conforming a token type whose
    // `token` is the bracketed form — no baked-in `.arbitrary()` helper needed.
    #expect(TW.bg(Custom(token: "[#bada55]"), .s500).rendered == "bg-[#bada55]-500")
  }

  @Test internal func customSizeClassAndRadius() {
    // A developer-defined size class / radius (the `@theme` extensibility point)
    // flows through the fluent surface just like a built-in.
    #expect(TW.text(Custom(token: "10xl")).rendered == "text-10xl")
    #expect(TW.rounded(Custom(token: "5xl")).rendered == "rounded-5xl")
  }

  @Test internal func builtInArbitraryStatics() {
    // Each extensible theme scale carries a documented `.arbitrary(_:)` escape.
    #expect(TW.maxW(.arbitrary("48rem")).rendered == "max-w-[48rem]")
    #expect(TW.gap(.arbitrary("13px")).rendered == "gap-[13px]")
    #expect(TW.w(.arbitrary("137px")).rendered == "w-[137px]")
    // Spaces become underscores (Tailwind restores them at build time).
    #expect(TW.gap(.arbitrary("1fr 500px")).rendered == "gap-[1fr_500px]")
  }
}
