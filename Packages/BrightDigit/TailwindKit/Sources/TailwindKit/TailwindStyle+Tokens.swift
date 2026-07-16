//
//  TailwindStyle+Tokens.swift
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
  ///
  /// Spelled `sNNN` because Swift identifiers cannot begin with a digit and
  /// leading underscores are disallowed — e.g. `.bg(.blue, .s500)`.
  public enum Shade: Int, Sendable, CaseIterable {
    case s50 = 50
    case s100 = 100
    case s200 = 200
    case s300 = 300
    case s400 = 400
    case s500 = 500
    case s600 = 600
    case s700 = 700
    case s800 = 800
    case s900 = 900
    case s950 = 950

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
    ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral
  {
    /// The `px` keyword (a single CSS pixel), e.g. `p-px`.
    public static let px = Spacing(token: "px")  // swiftlint:disable:this identifier_name

    /// The `auto` keyword, e.g. `mx-auto`.
    public static let auto = Spacing(token: "auto")

    internal let token: String

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

    private init(token: String) {
      self.token = token
    }

    /// A negative spacing value, e.g. `.neg(2)` on `.mx` → `-mx-2`.
    ///
    /// Tailwind emits negatives by prefixing the whole utility with `-`; the
    /// margin methods prepend the `-` when the token begins with one.
    public static func neg(_ value: Int) -> Spacing {
      Spacing(token: "-\(value)")
    }
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
    case xl2 = "2xl"
    case xl3 = "3xl"
    case xl4 = "4xl"
    case xl5 = "5xl"
    case xl6 = "6xl"
    case xl7 = "7xl"
    case xl8 = "8xl"
    case xl9 = "9xl"
    // swiftlint:enable identifier_name

    internal var token: String { rawValue }
  }

  /// A text-alignment keyword (the `center` in `text-center`).
  public enum TextAlign: String, Sendable, CaseIterable {
    case left, center, right, justify, start, end

    internal var token: String { rawValue }
  }

  /// A border-radius scale value (the `lg` in `rounded-lg`).
  ///
  /// Uses the Tailwind **v4** scale, where the small end was renamed: v3's
  /// `rounded-sm` (2px) became `rounded-xs`, and bare `rounded` (4px) became
  /// `rounded-sm`. `.base` renders bare `rounded`.
  public enum Radius: String, Sendable, CaseIterable {
    // swiftlint:disable identifier_name
    case none, xs, sm
    case base = ""
    case md, lg, xl
    case xl2 = "2xl"
    case xl3 = "3xl"
    case full
    // swiftlint:enable identifier_name

    internal var token: String { rawValue }
  }
}
