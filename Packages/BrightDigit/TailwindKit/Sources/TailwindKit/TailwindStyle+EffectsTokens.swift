//
//  TailwindStyle+EffectsTokens.swift
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
  /// A border-radius scale value (the `lg` in `rounded-lg`), backed by the
  /// `--radius-*` theme namespace.
  ///
  /// Uses the Tailwind **v4** scale, where the small end was renamed: v3's
  /// `rounded-sm` (2px) became `rounded-xs`, and bare `rounded` (4px) became
  /// `rounded-sm`. `.base` renders bare `rounded`. A protocol because
  /// `--radius-*` is `@theme`-extensible.
  public protocol Radius: TailwindToken {}

  /// The built-in Tailwind v4 border-radius values.
  public struct DefaultRadius: Radius {
    /// The rendered fragment, e.g. `"lg"`; `""` for the bare `rounded`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.Radius where Self == TailwindStyle.DefaultRadius {
  // swiftlint:disable identifier_name
  /// `rounded-none`.
  public static var none: TailwindStyle.DefaultRadius { .init("none") }
  /// `rounded-xs`.
  public static var xs: TailwindStyle.DefaultRadius { .init("xs") }
  /// `rounded-sm`.
  public static var sm: TailwindStyle.DefaultRadius { .init("sm") }
  /// Bare `rounded` (empty token).
  public static var base: TailwindStyle.DefaultRadius { .init("") }
  /// `rounded-md`.
  public static var md: TailwindStyle.DefaultRadius { .init("md") }
  /// `rounded-lg`.
  public static var lg: TailwindStyle.DefaultRadius { .init("lg") }
  /// `rounded-xl`.
  public static var xl: TailwindStyle.DefaultRadius { .init("xl") }
  // swiftlint:enable identifier_name
  /// `rounded-2xl`.
  public static var xl2: TailwindStyle.DefaultRadius { .init("2xl") }
  /// `rounded-3xl`.
  public static var xl3: TailwindStyle.DefaultRadius { .init("3xl") }
  /// `rounded-full`.
  public static var full: TailwindStyle.DefaultRadius { .init("full") }
}

// MARK: - Shadow

extension TailwindStyle {
  /// A box-shadow scale value (the `lg` in `shadow-lg`), backed by the
  /// `--shadow-*` theme namespace.
  ///
  /// Tailwind **v4** scale. The small end was renamed in v4 (v3 `shadow` → v4
  /// `shadow-sm`, new `shadow-xs`/`shadow-2xs` added); `lg`/`xl`/`2xl` are
  /// unchanged. A protocol because `--shadow-*` is `@theme`-extensible.
  public protocol Shadow: TailwindToken {}

  /// The built-in Tailwind v4 box-shadow values.
  public struct DefaultShadow: Shadow {
    /// The rendered fragment, e.g. `"lg"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.Shadow where Self == TailwindStyle.DefaultShadow {
  // swiftlint:disable identifier_name
  /// `shadow-2xs`.
  public static var xs2: TailwindStyle.DefaultShadow { .init("2xs") }
  /// `shadow-xs`.
  public static var xs: TailwindStyle.DefaultShadow { .init("xs") }
  /// `shadow-sm`.
  public static var sm: TailwindStyle.DefaultShadow { .init("sm") }
  /// `shadow-md`.
  public static var md: TailwindStyle.DefaultShadow { .init("md") }
  /// `shadow-lg`.
  public static var lg: TailwindStyle.DefaultShadow { .init("lg") }
  /// `shadow-xl`.
  public static var xl: TailwindStyle.DefaultShadow { .init("xl") }
  // swiftlint:enable identifier_name
  /// `shadow-2xl`.
  public static var xl2: TailwindStyle.DefaultShadow { .init("2xl") }
  /// `shadow-none`.
  public static var none: TailwindStyle.DefaultShadow { .init("none") }
}

// MARK: - DropShadow

extension TailwindStyle {
  /// A drop-shadow scale value (the `xl` in `drop-shadow-xl`), backed by the
  /// `--drop-shadow-*` theme namespace.
  ///
  /// A protocol because `--drop-shadow-*` is `@theme`-extensible.
  public protocol DropShadow: TailwindToken {}

  /// The built-in Tailwind v4 drop-shadow values.
  public struct DefaultDropShadow: DropShadow {
    /// The rendered fragment, e.g. `"xl"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.DropShadow where Self == TailwindStyle.DefaultDropShadow {
  // swiftlint:disable identifier_name
  /// `drop-shadow-xs`.
  public static var xs: TailwindStyle.DefaultDropShadow { .init("xs") }
  /// `drop-shadow-sm`.
  public static var sm: TailwindStyle.DefaultDropShadow { .init("sm") }
  /// `drop-shadow-md`.
  public static var md: TailwindStyle.DefaultDropShadow { .init("md") }
  /// `drop-shadow-lg`.
  public static var lg: TailwindStyle.DefaultDropShadow { .init("lg") }
  /// `drop-shadow-xl`.
  public static var xl: TailwindStyle.DefaultDropShadow { .init("xl") }
  // swiftlint:enable identifier_name
  /// `drop-shadow-2xl`.
  public static var xl2: TailwindStyle.DefaultDropShadow { .init("2xl") }
  /// `drop-shadow-none`.
  public static var none: TailwindStyle.DefaultDropShadow { .init("none") }
}

// MARK: - Ease

extension TailwindStyle {
  /// A transition-timing-function value (the `in-out` in `ease-in-out`), backed
  /// by the `--ease-*` theme namespace.
  ///
  /// A protocol because `--ease-*` is `@theme`-extensible (`ease-linear` is a
  /// hardcoded keyword, exposed here as a built-in for convenience).
  public protocol Ease: TailwindToken {}

  /// The built-in Tailwind v4 easing values.
  public struct DefaultEase: Ease {
    /// The rendered fragment, e.g. `"in-out"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.Ease where Self == TailwindStyle.DefaultEase {
  /// `ease-linear`.
  public static var linear: TailwindStyle.DefaultEase { .init("linear") }
  /// `ease-in`.
  public static var easeIn: TailwindStyle.DefaultEase { .init("in") }
  /// `ease-out`.
  public static var easeOut: TailwindStyle.DefaultEase { .init("out") }
  /// `ease-in-out`.
  public static var inOut: TailwindStyle.DefaultEase { .init("in-out") }
}
