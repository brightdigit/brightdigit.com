//
//  TailwindStyle+SpacingTokens.swift
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
  /// A value on Tailwind v4's dynamic spacing scale (the `4` in `gap-4`, the
  /// `2.5` in `p-2.5`), backed by the single `--spacing` theme multiplier that
  /// is reused across padding/margin/gap/inset/width/height/…
  ///
  /// A protocol because `--spacing` is `@theme`-customizable: conform your own
  /// type for a bespoke value. Built-ins render via literals (`.gap(4)`) and the
  /// `.px`/`.auto`/`.neg(_:)` static members on ``DefaultSpacing``.
  public protocol Spacing: TailwindToken {}

  /// The built-in spacing values — integer/float literals plus `px`/`auto` and
  /// the negative helper. Public type with no public initializer beyond the
  /// literal conformances, so it isn't constructed by name.
  public struct DefaultSpacing: Spacing,
    ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral
  {
    /// The rendered fragment, e.g. `"4"`, `"2.5"`, `"px"`.
    public let token: String

    /// Creates a spacing value from an integer literal (e.g. `4` renders `4`).
    public init(integerLiteral value: Int) {
      self.token = String(value)
    }

    /// Creates a spacing value from a floating-point literal, dropping a
    /// trailing `.0` (e.g. `2.5` renders `2.5`, `2.0` renders `2`).
    public init(floatLiteral value: Double) {
      self.token =
        value.rounded() == value
        ? String(Int(value))
        : String(value)
    }

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.Spacing where Self == TailwindStyle.DefaultSpacing {
  /// The `px` keyword (a single CSS pixel), e.g. `p-px`.
  public static var px: TailwindStyle.DefaultSpacing {  // swiftlint:disable:this identifier_name
    .init("px")
  }

  /// The `auto` keyword, e.g. `mx-auto`.
  public static var auto: TailwindStyle.DefaultSpacing { .init("auto") }

  /// A negative spacing value, e.g. `.neg(2)` on `.mx` → `-mx-2`.
  ///
  /// Tailwind emits negatives by prefixing the whole utility with `-`; the
  /// margin methods prepend the `-` when the token begins with one.
  public static func neg(_ value: Int) -> TailwindStyle.DefaultSpacing {
    .init("-\(value)")
  }

  /// A documented [arbitrary value](https://tailwindcss.com/docs/adding-custom-styles),
  /// e.g. `.arbitrary("13px")` on `.gap` → `gap-[13px]`. Spaces become
  /// underscores (Tailwind converts them back at build time).
  public static func arbitrary(_ value: String) -> TailwindStyle.DefaultSpacing {
    .init("[\(value.replacingOccurrences(of: " ", with: "_"))]")
  }
}

// MARK: - Size

extension TailwindStyle {
  /// A width/height value: a spacing-scale number (`w-4`), a keyword
  /// (`w-full`, `h-screen`), or a documented fraction (`w-1/2`).
  ///
  /// A protocol because the numeric part shares the extensible `--spacing`
  /// scale; conform your own type for a bespoke value. Built-ins render via
  /// literals and the keyword/`fraction(_:_:)` static members on ``DefaultSize``.
  public protocol Size: TailwindToken {}

  /// The built-in width/height values.
  public struct DefaultSize: Size,
    ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral
  {
    /// The rendered fragment, e.g. `"4"`, `"full"`, `"1/2"`.
    public let token: String

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

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.Size where Self == TailwindStyle.DefaultSize {
  /// `full` — 100%.
  public static var full: TailwindStyle.DefaultSize { .init("full") }
  /// `screen` — the viewport dimension.
  public static var screen: TailwindStyle.DefaultSize { .init("screen") }
  /// `auto`.
  public static var auto: TailwindStyle.DefaultSize { .init("auto") }
  /// `min` — `min-content`.
  public static var min: TailwindStyle.DefaultSize { .init("min") }
  /// `max` — `max-content`.
  public static var max: TailwindStyle.DefaultSize { .init("max") }
  /// `fit` — `fit-content`.
  public static var fit: TailwindStyle.DefaultSize { .init("fit") }

  /// A documented width fraction, e.g. `.fraction(1, 2)` → `w-1/2`.
  ///
  /// Tailwind v4 documents fractions with denominators 2–6 only; twelfths
  /// (`w-5/12`) are not a documented width utility, so they are not offered.
  public static func fraction(_ numerator: Int, _ denominator: Int)
    -> TailwindStyle.DefaultSize
  {
    .init("\(numerator)/\(denominator)")
  }

  /// A documented [arbitrary value](https://tailwindcss.com/docs/adding-custom-styles),
  /// e.g. `.arbitrary("137px")` on `.w` → `w-[137px]`. Spaces become underscores.
  public static func arbitrary(_ value: String) -> TailwindStyle.DefaultSize {
    .init("[\(value.replacingOccurrences(of: " ", with: "_"))]")
  }
}

// MARK: - MaxWidth

extension TailwindStyle {
  /// A `max-width` scale value (the `4xl` in `max-w-4xl`), backed by the
  /// `--container-*` theme namespace — the same scale that powers `@container`
  /// query variants.
  ///
  /// A protocol because `--container-*` is `@theme`-extensible; conform your own
  /// type for a bespoke value (including the documented arbitrary escape, e.g.
  /// a token of `"[48rem]"` → `max-w-[48rem]`).
  public protocol MaxWidth: TailwindToken {}

  /// The built-in `max-width` scale values plus `full`/`none`.
  public struct DefaultMaxWidth: MaxWidth {
    /// The rendered fragment, e.g. `"4xl"`, `"full"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.MaxWidth where Self == TailwindStyle.DefaultMaxWidth {
  // swiftlint:disable identifier_name
  /// `max-w-sm`.
  public static var sm: TailwindStyle.DefaultMaxWidth { .init("sm") }
  /// `max-w-lg`.
  public static var lg: TailwindStyle.DefaultMaxWidth { .init("lg") }
  // swiftlint:enable identifier_name
  /// `max-w-2xl`.
  public static var xl2: TailwindStyle.DefaultMaxWidth { .init("2xl") }
  /// `max-w-4xl`.
  public static var xl4: TailwindStyle.DefaultMaxWidth { .init("4xl") }
  /// `max-w-full`.
  public static var full: TailwindStyle.DefaultMaxWidth { .init("full") }
  /// `max-w-none`.
  public static var none: TailwindStyle.DefaultMaxWidth { .init("none") }

  /// A documented arbitrary max-width, e.g. `.arbitrary("48rem")` →
  /// `max-w-[48rem]`. Spaces become underscores.
  public static func arbitrary(_ value: String) -> TailwindStyle.DefaultMaxWidth {
    .init("[\(value.replacingOccurrences(of: " ", with: "_"))]")
  }
}
