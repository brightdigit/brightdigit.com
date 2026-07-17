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

extension TailwindStyleBuilder {
  /// A Tailwind **variant** prefix — the `md` in `md:flex`, the `hover` in
  /// `hover:bg-blue-700`.
  ///
  /// `Variant` is the value passed to ``TailwindStyleBuilder/prefixing(_:_:)`` and
  /// exposed through the responsive/state fluent members (`.md`, `.hover`, …).
  /// Variants compose by nesting — `.md(.hover(.bg(.blue, .s700)))` stacks the
  /// prefixes into `"md:hover:bg-blue-700"`.
  ///
  /// Like ``TailwindStyleBuilder/Color``, `Variant` is **extensible** (Tailwind lets
  /// you register custom variants, e.g. via `@custom-variant`): conform your own
  /// type to add one —
  ///
  /// ```swift
  /// struct SupportsGrid: TailwindStyleBuilder.Variant { let token = "supports-[display:grid]" }
  /// TW().prefixing(SupportsGrid(), .flex) // "supports-[display:grid]:flex"
  /// ```
  ///
  /// The documented built-ins are exposed as static members on
  /// ``TailwindStyleBuilder/DefaultVariant`` via the leading-dot syntax (`.md`, …).
  public protocol Variant: TailwindToken {}

  /// The built-in Tailwind variant prefixes.
  ///
  /// A `public` type (the return type of the static members below) with an
  /// `internal` initializer, so callers reference `.md`/`.hover` but never
  /// construct it directly — like ``TailwindStyleBuilder/DefaultColor``.
  public struct DefaultVariant: Variant {
    // swiftlint:disable identifier_name
    /// `sm:` — ≥ 40rem breakpoint.
    public static let sm = DefaultVariant("sm")
    /// `md:` — ≥ 48rem breakpoint.
    public static let md = DefaultVariant("md")
    /// `lg:` — ≥ 64rem breakpoint.
    public static let lg = DefaultVariant("lg")
    /// `xl:` — ≥ 80rem breakpoint.
    public static let xl = DefaultVariant("xl")
    // swiftlint:enable identifier_name
    /// `2xl:` — ≥ 96rem breakpoint.
    public static let xl2 = DefaultVariant("2xl")
    /// `hover:` state variant.
    public static let hover = DefaultVariant("hover")
    /// `focus:` state variant.
    public static let focus = DefaultVariant("focus")
    /// `active:` state variant.
    public static let active = DefaultVariant("active")
    /// `disabled:` state variant.
    public static let disabled = DefaultVariant("disabled")
    /// `group-hover:` state variant.
    public static let groupHover = DefaultVariant("group-hover")
    /// `dark:` color-scheme variant.
    public static let dark = DefaultVariant("dark")

    /// The rendered prefix, e.g. `"md"`, `"hover"`.
    public let token: String

    internal init(_ token: String) {
      self.token = token
    }
  }
}

extension TailwindStyleBuilder.Variant where Self == TailwindStyleBuilder.DefaultVariant {
  // swiftlint:disable identifier_name
  /// `sm:` — ≥ 40rem breakpoint.
  public static var sm: TailwindStyleBuilder.DefaultVariant { .sm }
  /// `md:` — ≥ 48rem breakpoint.
  public static var md: TailwindStyleBuilder.DefaultVariant { .md }
  /// `lg:` — ≥ 64rem breakpoint.
  public static var lg: TailwindStyleBuilder.DefaultVariant { .lg }
  /// `xl:` — ≥ 80rem breakpoint.
  public static var xl: TailwindStyleBuilder.DefaultVariant { .xl }
  // swiftlint:enable identifier_name
  /// `2xl:` — ≥ 96rem breakpoint.
  public static var xl2: TailwindStyleBuilder.DefaultVariant { .xl2 }
  /// `hover:` state variant.
  public static var hover: TailwindStyleBuilder.DefaultVariant { .hover }
  /// `focus:` state variant.
  public static var focus: TailwindStyleBuilder.DefaultVariant { .focus }
  /// `active:` state variant.
  public static var active: TailwindStyleBuilder.DefaultVariant { .active }
  /// `disabled:` state variant.
  public static var disabled: TailwindStyleBuilder.DefaultVariant { .disabled }
  /// `group-hover:` state variant.
  public static var groupHover: TailwindStyleBuilder.DefaultVariant { .groupHover }
  /// `dark:` color-scheme variant.
  public static var dark: TailwindStyleBuilder.DefaultVariant { .dark }
}
