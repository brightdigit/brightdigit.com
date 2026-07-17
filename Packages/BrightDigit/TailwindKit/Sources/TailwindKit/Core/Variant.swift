//
//  Variant.swift
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
  /// A Tailwind **variant** prefix — the `md` in `md:flex`, the `hover` in
  /// `hover:bg-blue-700`.
  ///
  /// `Variant` is the value passed to ``TailwindStyle/prefixing(_:_:)`` and
  /// exposed through the responsive/state fluent members (`.md`, `.hover`, …).
  /// Variants compose by nesting — `.md(.hover(.bg(.blue, .s700)))` stacks the
  /// prefixes into `"md:hover:bg-blue-700"`.
  ///
  /// Like ``TailwindStyle/Color``, `Variant` is **extensible** (Tailwind lets
  /// you register custom variants, e.g. via `@custom-variant`): conform your own
  /// type to add one —
  ///
  /// ```swift
  /// struct SupportsGrid: TailwindStyle.Variant { let token = "supports-[display:grid]" }
  /// TW().prefixing(SupportsGrid(), .flex) // "supports-[display:grid]:flex"
  /// ```
  ///
  /// The documented built-ins are exposed as static members on
  /// ``TailwindStyle/DefaultVariant`` via the leading-dot syntax (`.md`, …).
  public protocol Variant: TailwindToken {}

  /// The built-in Tailwind variant prefixes.
  ///
  /// A `public` type (the return type of the static members below) with an
  /// `internal` initializer, so callers reference `.md`/`.hover` but never
  /// construct it directly — like ``TailwindStyle/DefaultColor``.
  public struct DefaultVariant: Variant {
    /// The rendered prefix, e.g. `"md"`, `"hover"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyle.Variant where Self == TailwindStyle.DefaultVariant {
  // swiftlint:disable identifier_name
  /// `sm:` — ≥ 40rem breakpoint.
  public static var sm: TailwindStyle.DefaultVariant { .init("sm") }
  /// `md:` — ≥ 48rem breakpoint.
  public static var md: TailwindStyle.DefaultVariant { .init("md") }
  /// `lg:` — ≥ 64rem breakpoint.
  public static var lg: TailwindStyle.DefaultVariant { .init("lg") }
  /// `xl:` — ≥ 80rem breakpoint.
  public static var xl: TailwindStyle.DefaultVariant { .init("xl") }
  // swiftlint:enable identifier_name
  /// `2xl:` — ≥ 96rem breakpoint.
  public static var xl2: TailwindStyle.DefaultVariant { .init("2xl") }
  /// `hover:` state variant.
  public static var hover: TailwindStyle.DefaultVariant { .init("hover") }
  /// `focus:` state variant.
  public static var focus: TailwindStyle.DefaultVariant { .init("focus") }
  /// `active:` state variant.
  public static var active: TailwindStyle.DefaultVariant { .init("active") }
  /// `disabled:` state variant.
  public static var disabled: TailwindStyle.DefaultVariant { .init("disabled") }
  /// `group-hover:` state variant.
  public static var groupHover: TailwindStyle.DefaultVariant { .init("group-hover") }
  /// `dark:` color-scheme variant.
  public static var dark: TailwindStyle.DefaultVariant { .init("dark") }
}
