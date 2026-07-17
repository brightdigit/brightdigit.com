//
//  VariantStyling.swift
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

/// The responsive/state **variant** prefixes.
///
/// A capability protocol whose members are witnessed against the
/// ``TailwindStyleProtocol`` seam; ``TailwindStyle`` conforms to it. See
/// ``TailwindStyleProtocol`` for why the surface is organized this way.
///
/// Each member wraps a nested ``TailwindStyle`` and stacks a built-in
/// ``Variant`` prefix onto it via ``TailwindStyleProtocol/prefixing(_:_:)``.
/// Because the argument is itself a `TailwindStyle`, prefixes **stack by
/// nesting** — `.md(.hover(.bg(.blue, .s700)))` renders `"md:hover:bg-blue-700"`.
///
/// Responsive breakpoints:
/// - `sm` — ≥ 40rem
/// - `md` — ≥ 48rem
/// - `lg` — ≥ 64rem
/// - `xl` — ≥ 80rem
/// - `xl2` (`2xl`) — ≥ 96rem
public protocol VariantStyling {
  /// `sm:…` — ≥ 40rem breakpoint.
  func sm(_ style: TailwindStyle) -> Self
  /// `md:…` — ≥ 48rem breakpoint.
  func md(_ style: TailwindStyle) -> Self
  /// `lg:…` — ≥ 64rem breakpoint.
  func lg(_ style: TailwindStyle) -> Self
  /// `xl:…` — ≥ 80rem breakpoint.
  func xl(_ style: TailwindStyle) -> Self
  /// `2xl:…` — ≥ 96rem breakpoint.
  func xl2(_ style: TailwindStyle) -> Self
  /// `hover:…` state variant.
  func hover(_ style: TailwindStyle) -> Self
  /// `focus:…` state variant.
  func focus(_ style: TailwindStyle) -> Self
  /// `active:…` state variant.
  func active(_ style: TailwindStyle) -> Self
  /// `disabled:…` state variant.
  func disabled(_ style: TailwindStyle) -> Self
  /// `group-hover:…` state variant.
  func groupHover(_ style: TailwindStyle) -> Self
  /// `dark:…` color-scheme variant.
  func dark(_ style: TailwindStyle) -> Self
}

extension VariantStyling where Self: TailwindStyleProtocol {
  /// `sm:…` — ≥ 40rem breakpoint.
  public func sm(_ style: TailwindStyle) -> Self { prefixing(.sm, style) }
  /// `md:…` — ≥ 48rem breakpoint.
  public func md(_ style: TailwindStyle) -> Self { prefixing(.md, style) }
  /// `lg:…` — ≥ 64rem breakpoint.
  public func lg(_ style: TailwindStyle) -> Self { prefixing(.lg, style) }
  /// `xl:…` — ≥ 80rem breakpoint.
  public func xl(_ style: TailwindStyle) -> Self { prefixing(.xl, style) }
  /// `2xl:…` — ≥ 96rem breakpoint.
  public func xl2(_ style: TailwindStyle) -> Self { prefixing(.xl2, style) }
  /// `hover:…` state variant.
  public func hover(_ style: TailwindStyle) -> Self { prefixing(.hover, style) }
  /// `focus:…` state variant.
  public func focus(_ style: TailwindStyle) -> Self { prefixing(.focus, style) }
  /// `active:…` state variant.
  public func active(_ style: TailwindStyle) -> Self { prefixing(.active, style) }
  /// `disabled:…` state variant.
  public func disabled(_ style: TailwindStyle) -> Self { prefixing(.disabled, style) }
  /// `group-hover:…` state variant.
  public func groupHover(_ style: TailwindStyle) -> Self { prefixing(.groupHover, style) }
  /// `dark:…` color-scheme variant.
  public func dark(_ style: TailwindStyle) -> Self { prefixing(.dark, style) }
}

extension TailwindStyle: VariantStyling {}

// Static mirrors so a variant can start a chain with a leading dot.
extension TailwindStyle {
  /// `sm:…` — ≥ 40rem breakpoint.
  public static func sm(_ style: TailwindStyle) -> TailwindStyle { TailwindStyle().sm(style) }
  /// `md:…` — ≥ 48rem breakpoint.
  public static func md(_ style: TailwindStyle) -> TailwindStyle { TailwindStyle().md(style) }
  /// `lg:…` — ≥ 64rem breakpoint.
  public static func lg(_ style: TailwindStyle) -> TailwindStyle { TailwindStyle().lg(style) }
  /// `xl:…` — ≥ 80rem breakpoint.
  public static func xl(_ style: TailwindStyle) -> TailwindStyle { TailwindStyle().xl(style) }
  /// `2xl:…` — ≥ 96rem breakpoint.
  public static func xl2(_ style: TailwindStyle) -> TailwindStyle { TailwindStyle().xl2(style) }
  /// `hover:…` state variant.
  public static func hover(_ style: TailwindStyle) -> TailwindStyle { TailwindStyle().hover(style) }
  /// `focus:…` state variant.
  public static func focus(_ style: TailwindStyle) -> TailwindStyle { TailwindStyle().focus(style) }
  /// `active:…` state variant.
  public static func active(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().active(style)
  }
  /// `disabled:…` state variant.
  public static func disabled(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().disabled(style)
  }
  /// `group-hover:…` state variant.
  public static func groupHover(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().groupHover(style)
  }
  /// `dark:…` color-scheme variant.
  public static func dark(_ style: TailwindStyle) -> TailwindStyle { TailwindStyle().dark(style) }
}
