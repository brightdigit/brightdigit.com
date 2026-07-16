//
//  TailwindStyle+TypographyTokens.swift
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
  /// A font size on the `text-*` scale (the `lg` in `text-lg`), backed by the
  /// `--text-*` theme namespace.
  ///
  /// A protocol because `--text-*` is `@theme`-extensible: conform your own type
  /// to add a custom size class (e.g. `text-tiny`, `text-10xl`).
  public protocol TextSize: TailwindToken {}

  /// The built-in Tailwind v4 font sizes.
  public struct DefaultTextSize: TextSize {
    /// The rendered fragment, e.g. `"lg"`, `"2xl"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.TextSize where Self == TailwindStyle.DefaultTextSize {
  // swiftlint:disable identifier_name
  /// `text-xs`.
  public static var xs: TailwindStyle.DefaultTextSize { .init("xs") }
  /// `text-sm`.
  public static var sm: TailwindStyle.DefaultTextSize { .init("sm") }
  /// `text-base`.
  public static var base: TailwindStyle.DefaultTextSize { .init("base") }
  /// `text-lg`.
  public static var lg: TailwindStyle.DefaultTextSize { .init("lg") }
  /// `text-xl`.
  public static var xl: TailwindStyle.DefaultTextSize { .init("xl") }
  // swiftlint:enable identifier_name
  /// `text-2xl`.
  public static var xl2: TailwindStyle.DefaultTextSize { .init("2xl") }
  /// `text-3xl`.
  public static var xl3: TailwindStyle.DefaultTextSize { .init("3xl") }
  /// `text-4xl`.
  public static var xl4: TailwindStyle.DefaultTextSize { .init("4xl") }
  /// `text-5xl`.
  public static var xl5: TailwindStyle.DefaultTextSize { .init("5xl") }
  /// `text-6xl`.
  public static var xl6: TailwindStyle.DefaultTextSize { .init("6xl") }
  /// `text-7xl`.
  public static var xl7: TailwindStyle.DefaultTextSize { .init("7xl") }
  /// `text-8xl`.
  public static var xl8: TailwindStyle.DefaultTextSize { .init("8xl") }
  /// `text-9xl`.
  public static var xl9: TailwindStyle.DefaultTextSize { .init("9xl") }
}

// MARK: - FontWeight

extension TailwindStyle {
  /// A font weight (the `medium` in `font-medium`), backed by the
  /// `--font-weight-*` theme namespace.
  ///
  /// A protocol because `--font-weight-*` is `@theme`-extensible.
  public protocol FontWeight: TailwindToken {}

  /// The built-in Tailwind v4 font weights.
  public struct DefaultFontWeight: FontWeight {
    /// The rendered fragment, e.g. `"medium"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.FontWeight where Self == TailwindStyle.DefaultFontWeight {
  /// `font-thin`.
  public static var thin: TailwindStyle.DefaultFontWeight { .init("thin") }
  /// `font-extralight`.
  public static var extralight: TailwindStyle.DefaultFontWeight { .init("extralight") }
  /// `font-light`.
  public static var light: TailwindStyle.DefaultFontWeight { .init("light") }
  /// `font-normal`.
  public static var normal: TailwindStyle.DefaultFontWeight { .init("normal") }
  /// `font-medium`.
  public static var medium: TailwindStyle.DefaultFontWeight { .init("medium") }
  /// `font-semibold`.
  public static var semibold: TailwindStyle.DefaultFontWeight { .init("semibold") }
  /// `font-bold`.
  public static var bold: TailwindStyle.DefaultFontWeight { .init("bold") }
  /// `font-extrabold`.
  public static var extrabold: TailwindStyle.DefaultFontWeight { .init("extrabold") }
  /// `font-black`.
  public static var black: TailwindStyle.DefaultFontWeight { .init("black") }
}

// MARK: - Tracking

extension TailwindStyle {
  /// A `letter-spacing` value (the `tight` in `tracking-tight`), backed by the
  /// `--tracking-*` theme namespace.
  ///
  /// A protocol because `--tracking-*` is `@theme`-extensible.
  public protocol Tracking: TailwindToken {}

  /// The built-in Tailwind v4 letter-spacing values.
  public struct DefaultTracking: Tracking {
    /// The rendered fragment, e.g. `"tight"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.Tracking where Self == TailwindStyle.DefaultTracking {
  /// `tracking-tighter`.
  public static var tighter: TailwindStyle.DefaultTracking { .init("tighter") }
  /// `tracking-tight`.
  public static var tight: TailwindStyle.DefaultTracking { .init("tight") }
  /// `tracking-normal`.
  public static var normal: TailwindStyle.DefaultTracking { .init("normal") }
  /// `tracking-wide`.
  public static var wide: TailwindStyle.DefaultTracking { .init("wide") }
  /// `tracking-wider`.
  public static var wider: TailwindStyle.DefaultTracking { .init("wider") }
  /// `tracking-widest`.
  public static var widest: TailwindStyle.DefaultTracking { .init("widest") }
}
