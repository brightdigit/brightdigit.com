//
//  TailwindTokens.swift
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

// MARK: - Colors

extension TailwindStyle {
  /// A Tailwind v4 color family (the `blue` in `bg-blue-500`).
  public enum Color: String, Sendable, CaseIterable {
    case slate, gray, zinc, neutral, stone
    case red, orange, amber, yellow, lime
    case green, emerald, teal, cyan, sky
    case blue, indigo, violet, purple, fuchsia
    case pink, rose

    /// The token fragment, e.g. `"blue"`.
    internal var token: String { rawValue }
  }

  /// A Tailwind v4 color shade (the `500` in `bg-blue-500`).
  public enum Shade: Int, Sendable, CaseIterable {
    // swiftlint:disable identifier_name
    case _50 = 50, _100 = 100, _200 = 200, _300 = 300, _400 = 400
    case _500 = 500, _600 = 600, _700 = 700, _800 = 800, _900 = 900
    case _950 = 950
    // swiftlint:enable identifier_name

    /// The token fragment, e.g. `"500"`.
    internal var token: String { String(rawValue) }
  }
}

// MARK: - Spacing

extension TailwindStyle {
  /// A value on Tailwind v4's dynamic spacing scale (the `4` in `gap-4`,
  /// the `2.5` in `p-2.5`).
  ///
  /// Expressible by integer and floating-point literals so call sites read
  /// naturally: `.gap(4)`, `.p(2.5)`.
  public struct Spacing: Sendable, Equatable, Hashable,
    ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    internal let token: String

    public init(integerLiteral value: Int) {
      self.token = String(value)
    }

    public init(floatLiteral value: Double) {
      // Drop a trailing ".0" so 2.0 renders as "2", 2.5 stays "2.5".
      self.token = value.rounded() == value
        ? String(Int(value))
        : String(value)
    }

    /// The `px` keyword (a single CSS pixel), e.g. `p-px`.
    public static let px = Spacing(token: "px")

    private init(token: String) {
      self.token = token
    }
  }
}

// MARK: - Sizing

extension TailwindStyle {
  /// A width/height value: a spacing-scale number (`w-4`) or a keyword
  /// (`w-full`, `h-screen`).
  public struct Size: Sendable, Equatable, Hashable,
    ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    internal let token: String

    public init(integerLiteral value: Int) {
      self.token = String(value)
    }

    public init(floatLiteral value: Double) {
      self.token = value.rounded() == value
        ? String(Int(value))
        : String(value)
    }

    private init(token: String) {
      self.token = token
    }

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
  }
}

// MARK: - Flex / Grid alignment

extension TailwindStyle {
  /// Cross-axis alignment for `items-*` (`align-items`).
  public enum Align: String, Sendable, CaseIterable {
    case start, center, end, baseline, stretch

    internal var token: String { rawValue }
  }

  /// Main-axis distribution for `justify-*` (`justify-content`).
  public enum Justify: String, Sendable, CaseIterable {
    case start, center, end, between, around, evenly

    internal var token: String { rawValue }
  }
}

// MARK: - Typography

extension TailwindStyle {
  /// A font weight (the `medium` in `font-medium`).
  public enum FontWeight: String, Sendable, CaseIterable {
    case thin, extralight, light, normal, medium
    case semibold, bold, extrabold, black

    internal var token: String { rawValue }
  }

  /// A font size on the `text-*` scale (the `lg` in `text-lg`).
  public enum TextSize: String, Sendable, CaseIterable {
    // swiftlint:disable identifier_name
    case xs, sm, base, lg, xl
    case xl2 = "2xl", xl3 = "3xl", xl4 = "4xl", xl5 = "5xl"
    case xl6 = "6xl", xl7 = "7xl", xl8 = "8xl", xl9 = "9xl"
    // swiftlint:enable identifier_name

    internal var token: String { rawValue }
  }

  /// A text-alignment keyword (the `center` in `text-center`).
  public enum TextAlign: String, Sendable, CaseIterable {
    case left, center, right, justify, start, end

    internal var token: String { rawValue }
  }

  /// A border-radius scale value (the `lg` in `rounded-lg`).
  public enum Radius: String, Sendable, CaseIterable {
    // swiftlint:disable identifier_name
    case none, sm, base = "", md, lg, xl
    case xl2 = "2xl", xl3 = "3xl", full
    // swiftlint:enable identifier_name

    internal var token: String { rawValue }
  }
}
