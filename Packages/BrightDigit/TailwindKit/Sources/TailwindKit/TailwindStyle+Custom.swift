//
//  TailwindStyle+Custom.swift
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
  /// A [Tailwind v4 arbitrary value](https://tailwindcss.com/docs/adding-custom-styles) —
  /// the bracketed (`[…]`) or parenthesized (`(…)`) part of a one-off utility
  /// such as `top-[117px]` or `bg-(--brand)`.
  ///
  /// This is the deliberate, type-safe escape hatch for the documented
  /// "break out of the constraints" cases. The utility *prefix* is still
  /// supplied by the caller (`w`, `top`, `bg`, …); `Custom` only models the
  /// value, so it can never emit a free-form class name.
  public struct Custom: Sendable, Equatable, Hashable {
    /// The rendered value fragment, e.g. `"[117px]"` or `"(--brand)"`.
    internal let token: String

    private init(token: String) {
      self.token = token
    }

    /// A literal arbitrary value in square brackets, e.g.
    /// `.value("117px")` → `[117px]`, `.value("#bada55")` → `[#bada55]`.
    ///
    /// Per Tailwind's whitespace rule, spaces are converted to underscores at
    /// build time, so `.value("1fr 500px")` → `[1fr_500px]`.
    public static func value(_ value: String) -> Custom {
      Custom(token: "[\(Self.escapingSpaces(value))]")
    }

    /// A CSS custom-property (variable) value in parentheses, e.g.
    /// `.variable("--brand")` → `(--brand)`.
    ///
    /// This is Tailwind v4's shorthand for `[var(--brand)]`; it adds the
    /// `var()` wrapper for you at build time.
    public static func variable(_ name: String) -> Custom {
      Custom(token: "(\(name))")
    }

    /// Replaces spaces with underscores (Tailwind converts them back to spaces
    /// at build time); existing underscores are preserved verbatim.
    private static func escapingSpaces(_ value: String) -> String {
      value.replacingOccurrences(of: " ", with: "_")
    }
  }
}

extension TailwindStyle {
  /// A utility built from a prefix and a Tailwind v4 arbitrary value:
  /// `<prefix>-[value]` or `<prefix>-(--var)`.
  ///
  /// ```swift
  /// TW.custom("top", .value("117px")).rendered   // "top-[117px]"
  /// TW.custom("bg", .value("#bada55")).rendered   // "bg-[#bada55]"
  /// TW.custom("bg", .variable("--brand")).rendered // "bg-(--brand)"
  /// ```
  public func custom(_ prefix: String, _ value: Custom) -> TailwindStyle {
    appending("\(prefix)-\(value.token)")
  }

  /// A fully arbitrary CSS property (no utility prefix): `[property:value]`,
  /// e.g. `.custom(property: "mask-type", value: "luminance")` →
  /// `[mask-type:luminance]`. Spaces in the value become underscores.
  public func custom(property: String, value: String) -> TailwindStyle {
    appending("[\(property):\(value.replacingOccurrences(of: " ", with: "_"))]")
  }
}

// Static mirrors so a chain can start with a custom value.
extension TailwindStyle {
  /// `<prefix>-[value]` / `<prefix>-(--var)`, e.g. `.custom("top", .value("117px"))`.
  public static func custom(_ prefix: String, _ value: Custom) -> TailwindStyle {
    TailwindStyle().custom(prefix, value)
  }

  /// `[property:value]`, e.g. `.custom(property: "mask-type", value: "luminance")`.
  public static func custom(property: String, value: String) -> TailwindStyle {
    TailwindStyle().custom(property: property, value: value)
  }
}
