//
//  TailwindStyle+ColorTokens.swift
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
  /// A Tailwind v4 color family (the `blue` in `bg-blue-500`), backed by the
  /// `--color-*` theme namespace and reused across `bg`/`text`/`border`/`ring`/…
  ///
  /// The documented palette is exposed as static members (`.blue`, `.slate`, …).
  /// Because `--color-*` is `@theme`-extensible, `Color` is a protocol: add a
  /// custom family by conforming your own type — e.g.
  /// `struct BrandColor: TailwindStyle.Color { let token = "brand" }` plus an
  /// `extension … where Self == BrandColor { static var brand: … }` for the
  /// leading-dot spelling — then `.bg(.brand, .s500)`.
  public protocol Color: TailwindToken {}

  /// The built-in Tailwind v4 color families.
  ///
  /// A `public` type (its name is the return type of the static members below)
  /// with no public initializer, so callers reference `.blue` but never
  /// construct it directly — like SwiftUI's `DefaultButtonStyle`.
  public struct DefaultColor: Color {
    /// The rendered fragment, e.g. `"blue"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.Color where Self == TailwindStyle.DefaultColor {
  /// `slate`.
  public static var slate: TailwindStyle.DefaultColor { .init("slate") }
  /// `gray`.
  public static var gray: TailwindStyle.DefaultColor { .init("gray") }
  /// `zinc`.
  public static var zinc: TailwindStyle.DefaultColor { .init("zinc") }
  /// `neutral`.
  public static var neutral: TailwindStyle.DefaultColor { .init("neutral") }
  /// `stone`.
  public static var stone: TailwindStyle.DefaultColor { .init("stone") }
  /// `red`.
  public static var red: TailwindStyle.DefaultColor { .init("red") }
  /// `orange`.
  public static var orange: TailwindStyle.DefaultColor { .init("orange") }
  /// `amber`.
  public static var amber: TailwindStyle.DefaultColor { .init("amber") }
  /// `yellow`.
  public static var yellow: TailwindStyle.DefaultColor { .init("yellow") }
  /// `lime`.
  public static var lime: TailwindStyle.DefaultColor { .init("lime") }
  /// `green`.
  public static var green: TailwindStyle.DefaultColor { .init("green") }
  /// `emerald`.
  public static var emerald: TailwindStyle.DefaultColor { .init("emerald") }
  /// `teal`.
  public static var teal: TailwindStyle.DefaultColor { .init("teal") }
  /// `cyan`.
  public static var cyan: TailwindStyle.DefaultColor { .init("cyan") }
  /// `sky`.
  public static var sky: TailwindStyle.DefaultColor { .init("sky") }
  /// `blue`.
  public static var blue: TailwindStyle.DefaultColor { .init("blue") }
  /// `indigo`.
  public static var indigo: TailwindStyle.DefaultColor { .init("indigo") }
  /// `violet`.
  public static var violet: TailwindStyle.DefaultColor { .init("violet") }
  /// `purple`.
  public static var purple: TailwindStyle.DefaultColor { .init("purple") }
  /// `fuchsia`.
  public static var fuchsia: TailwindStyle.DefaultColor { .init("fuchsia") }
  /// `pink`.
  public static var pink: TailwindStyle.DefaultColor { .init("pink") }
  /// `rose`.
  public static var rose: TailwindStyle.DefaultColor { .init("rose") }
}

extension TailwindStyle {
  /// A Tailwind v4 color shade (the `500` in `bg-blue-500`).
  ///
  /// Spelled `sNNN` because Swift identifiers cannot begin with a digit — e.g.
  /// `.bg(.blue, .s500)`. Unlike ``Color``, shade is a **fixed** 11-step scale,
  /// not an extensible theme namespace: in Tailwind v4 `blue-500` is a single
  /// variable `--color-blue-500`, so a "custom shade" is not a coherent concept
  /// (you would define a whole new ``Color`` instead). Hence a closed enum.
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
