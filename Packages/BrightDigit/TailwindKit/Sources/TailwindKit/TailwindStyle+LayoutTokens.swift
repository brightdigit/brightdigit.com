//
//  TailwindStyle+LayoutTokens.swift
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
  /// A width/height value: a spacing-scale number (`w-4`) or a keyword
  /// (`w-full`, `h-screen`).
  public struct Size: Sendable, Equatable, Hashable,
    ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral
  {
    /// `full` — 100%.
    public static let full = Size(token: "full")
    /// `screen` — the viewport dimension.
    public static let screen = Size(token: "screen")
    /// `auto`.
    public static let auto = Size(token: "auto")
    /// `min` — `min-content`.
    public static let min = Size(token: "min")
    /// `max` — `max-content`.
    public static let max = Size(token: "max")
    /// `fit` — `fit-content`.
    public static let fit = Size(token: "fit")

    internal let token: String

    /// Creates a size from an integer literal on the spacing scale (e.g. `4`).
    public init(integerLiteral value: Int) {
      self.token = String(value)
    }

    /// Creates a size from a floating-point literal, dropping a trailing `.0`.
    public init(floatLiteral value: Double) {
      self.token =
        value.rounded() == value
        ? String(Int(value))
        : String(value)
    }

    private init(token: String) {
      self.token = token
    }

    /// A documented width fraction, e.g. `.fraction(1, 2)` → `w-1/2`.
    ///
    /// Tailwind v4 documents fractions with denominators 2–6 only; twelfths
    /// (`w-5/12`) are not a documented width utility, so they are not offered.
    public static func fraction(_ numerator: Int, _ denominator: Int) -> Size {
      Size(token: "\(numerator)/\(denominator)")
    }
  }

  /// A `max-width` scale value (the `4xl` in `max-w-4xl`).
  ///
  /// Covers the documented container-scale sizes plus `full`/`none` and the
  /// documented arbitrary-value escape (`.arbitrary("48rem")` → `max-w-[48rem]`).
  public struct MaxWidth: Sendable, Equatable, Hashable {
    // swiftlint:disable identifier_name
    /// `max-w-sm`.
    public static let sm = MaxWidth(token: "sm")
    /// `max-w-lg`.
    public static let lg = MaxWidth(token: "lg")
    // swiftlint:enable identifier_name
    /// `max-w-2xl`.
    public static let xl2 = MaxWidth(token: "2xl")
    /// `max-w-4xl`.
    public static let xl4 = MaxWidth(token: "4xl")
    /// `max-w-full`.
    public static let full = MaxWidth(token: "full")
    /// `max-w-none`.
    public static let none = MaxWidth(token: "none")

    internal let token: String

    private init(token: String) {
      self.token = token
    }

    /// A documented arbitrary max-width, e.g. `.arbitrary("48rem")` →
    /// `max-w-[48rem]`.
    public static func arbitrary(_ value: String) -> MaxWidth {
      MaxWidth(token: "[\(value)]")
    }
  }

  /// A box-shadow scale value (the `lg` in `shadow-lg`).
  ///
  /// Tailwind **v4** scale. Note the small end was renamed in v4 (v3 `shadow`
  /// → v4 `shadow-sm`, new `shadow-xs`/`shadow-2xs` added); `lg`/`xl`/`2xl`
  /// are unchanged.
  public enum Shadow: String, Sendable, CaseIterable {
    // swiftlint:disable identifier_name
    case xs2 = "2xs"
    case xs, sm, md, lg, xl
    case xl2 = "2xl"
    case none
    // swiftlint:enable identifier_name

    internal var token: String { rawValue }
  }

  /// A drop-shadow scale value (the `xl` in `drop-shadow-xl`).
  public enum DropShadow: String, Sendable, CaseIterable {
    // swiftlint:disable identifier_name
    case xs, sm, md, lg, xl
    case xl2 = "2xl"
    case none
    // swiftlint:enable identifier_name

    internal var token: String { rawValue }
  }

  /// An `object-fit` keyword (the `cover` in `object-cover`).
  public enum ObjectFit: String, Sendable, CaseIterable {
    case contain, cover, fill, none
    case scaleDown = "scale-down"

    internal var token: String { rawValue }
  }

  /// A transition-timing-function keyword (the `in-out` in `ease-in-out`).
  public enum Ease: String, Sendable, CaseIterable {
    case linear
    case easeIn = "in"
    case easeOut = "out"
    case inOut = "in-out"

    internal var token: String { rawValue }
  }

  /// A `vertical-align` keyword (the `middle` in `align-middle`).
  public enum VerticalAlign: String, Sendable, CaseIterable {
    case baseline, top, middle, bottom
    case textTop = "text-top"
    case textBottom = "text-bottom"
    case sub, `super`

    internal var token: String { rawValue }
  }

  /// A single box side for `border-{t,r,b,l}-<n>` width utilities.
  public enum BorderSide: String, Sendable, CaseIterable {
    case top = "t"
    case right = "r"
    case bottom = "b"
    case left = "l"

    internal var token: String { rawValue }
  }

  /// A `letter-spacing` keyword (the `tight` in `tracking-tight`).
  public enum Tracking: String, Sendable, CaseIterable {
    case tighter, tight, normal, wide, wider, widest

    internal var token: String { rawValue }
  }
}
