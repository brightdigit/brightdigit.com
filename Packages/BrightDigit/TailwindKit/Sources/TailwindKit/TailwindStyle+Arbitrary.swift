//
//  TailwindStyle+Arbitrary.swift
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

extension TailwindStyle {
  /// `<prefix>-[value]`, e.g. `.arbitrary("top", value: "117px")` →
  /// `top-[117px]`, `.arbitrary("bg", value: "#bada55")` → `bg-[#bada55]`.
  ///
  /// Per Tailwind's whitespace rule, spaces become underscores at build time,
  /// so `.arbitrary("grid-cols", value: "1fr 500px")` → `grid-cols-[1fr_500px]`.
  public func arbitrary(_ prefix: String, value: String) -> TailwindStyle {
    appending("\(prefix)-[\(escapingSpaces(value))]")
  }

  /// `<prefix>-(--var)`, e.g. `.arbitrary("bg", variable: "--brand")` →
  /// `bg-(--brand)`. This is Tailwind v4's shorthand for `[var(--brand)]`.
  public func arbitrary(_ prefix: String, variable name: String) -> TailwindStyle {
    appending("\(prefix)-(\(name))")
  }

  /// A fully arbitrary CSS property (no utility prefix): `[property:value]`,
  /// e.g. `.custom(property: "mask-type", value: "luminance")` →
  /// `[mask-type:luminance]`. Spaces in the value become underscores.
  public func custom(property: String, value: String) -> TailwindStyle {
    appending("[\(property):\(escapingSpaces(value))]")
  }

  /// Replaces spaces with underscores (Tailwind converts them back to spaces at
  /// build time); existing underscores are preserved verbatim.
  private func escapingSpaces(_ value: String) -> String {
    value.replacingOccurrences(of: " ", with: "_")
  }
}

// Static mirrors so an arbitrary value can start a chain with a leading dot.
extension TailwindStyle {
  /// `<prefix>-[value]`, e.g. `.arbitrary("top", value: "117px")`.
  public static func arbitrary(_ prefix: String, value: String) -> TailwindStyle {
    TailwindStyle().arbitrary(prefix, value: value)
  }

  /// `<prefix>-(--var)`, e.g. `.arbitrary("bg", variable: "--brand")`.
  public static func arbitrary(_ prefix: String, variable name: String) -> TailwindStyle {
    TailwindStyle().arbitrary(prefix, variable: name)
  }

  /// `[property:value]`, e.g. `.custom(property: "mask-type", value: "luminance")`.
  public static func custom(property: String, value: String) -> TailwindStyle {
    TailwindStyle().custom(property: property, value: value)
  }
}
