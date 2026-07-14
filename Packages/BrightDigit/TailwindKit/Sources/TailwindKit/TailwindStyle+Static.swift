//
//  TailwindStyle+Static.swift
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

// Static mirrors of every instance utility in `TailwindStyle+Utilities.swift`,
// each forwarding to the empty style. These let a chain start with a leading
// dot — required for `TW.flex…` and for the
// `.tailwind(.flex.items(.center).gap)` Plot call site, where the argument type
// is inferred as `TailwindStyle`. See the instance members for per-utility docs.
// Bare utilities are properties; parameterized ones are methods (kept in a
// second extension so properties precede methods).

// MARK: - Bare utilities (type properties)

extension TailwindStyle {
  // MARK: Display

  public static var flex: TailwindStyle { TailwindStyle().flex }
  public static var inlineFlex: TailwindStyle { TailwindStyle().inlineFlex }
  public static var grid: TailwindStyle { TailwindStyle().grid }
  public static var block: TailwindStyle { TailwindStyle().block }
  public static var inlineBlock: TailwindStyle { TailwindStyle().inlineBlock }
  public static var inline: TailwindStyle { TailwindStyle().inline }
  public static var hidden: TailwindStyle { TailwindStyle().hidden }

  // MARK: Flexbox & grid

  public static var flexRow: TailwindStyle { TailwindStyle().flexRow }
  public static var flexCol: TailwindStyle { TailwindStyle().flexCol }
  public static var flexWrap: TailwindStyle { TailwindStyle().flexWrap }
  public static var grow: TailwindStyle { TailwindStyle().grow }
  public static var shrink: TailwindStyle { TailwindStyle().shrink }
  public static var gap: TailwindStyle { TailwindStyle().gap }

  // MARK: Colors

  public static var bgWhite: TailwindStyle { TailwindStyle().bgWhite }
  public static var bgBlack: TailwindStyle { TailwindStyle().bgBlack }
  public static var bgTransparent: TailwindStyle { TailwindStyle().bgTransparent }

  // MARK: Typography

  public static var textWhite: TailwindStyle { TailwindStyle().textWhite }
  public static var textBlack: TailwindStyle { TailwindStyle().textBlack }
  public static var italic: TailwindStyle { TailwindStyle().italic }
  public static var underline: TailwindStyle { TailwindStyle().underline }
  public static var uppercase: TailwindStyle { TailwindStyle().uppercase }
  public static var lowercase: TailwindStyle { TailwindStyle().lowercase }
  public static var capitalize: TailwindStyle { TailwindStyle().capitalize }

  // MARK: Borders & radius

  public static var border: TailwindStyle { TailwindStyle().border }
  public static var rounded: TailwindStyle { TailwindStyle().rounded }
}

// MARK: - Parameterized utilities (type methods)

extension TailwindStyle {
  // MARK: Flexbox & grid

  public static func items(_ align: Align) -> TailwindStyle {
    TailwindStyle().items(align)
  }
  public static func justify(_ value: Justify) -> TailwindStyle {
    TailwindStyle().justify(value)
  }
  public static func gridCols(_ count: Int) -> TailwindStyle {
    TailwindStyle().gridCols(count)
  }
  public static func gap(_ amount: Spacing) -> TailwindStyle {
    TailwindStyle().gap(amount)
  }
  public static func gapX(_ amount: Spacing) -> TailwindStyle {
    TailwindStyle().gapX(amount)
  }
  public static func gapY(_ amount: Spacing) -> TailwindStyle {
    TailwindStyle().gapY(amount)
  }

  // MARK: Spacing

  public static func p(_ amount: Spacing) -> TailwindStyle { TailwindStyle().p(amount) }
  public static func px(_ amount: Spacing) -> TailwindStyle { TailwindStyle().px(amount) }
  public static func py(_ amount: Spacing) -> TailwindStyle { TailwindStyle().py(amount) }
  public static func pt(_ amount: Spacing) -> TailwindStyle { TailwindStyle().pt(amount) }
  public static func pr(_ amount: Spacing) -> TailwindStyle { TailwindStyle().pr(amount) }
  public static func pb(_ amount: Spacing) -> TailwindStyle { TailwindStyle().pb(amount) }
  public static func pl(_ amount: Spacing) -> TailwindStyle { TailwindStyle().pl(amount) }
  public static func m(_ amount: Spacing) -> TailwindStyle { TailwindStyle().m(amount) }
  public static func mx(_ amount: Spacing) -> TailwindStyle { TailwindStyle().mx(amount) }
  public static func my(_ amount: Spacing) -> TailwindStyle { TailwindStyle().my(amount) }
  public static func mt(_ amount: Spacing) -> TailwindStyle { TailwindStyle().mt(amount) }
  public static func mr(_ amount: Spacing) -> TailwindStyle { TailwindStyle().mr(amount) }
  public static func mb(_ amount: Spacing) -> TailwindStyle { TailwindStyle().mb(amount) }
  public static func ml(_ amount: Spacing) -> TailwindStyle { TailwindStyle().ml(amount) }

  // MARK: Sizing

  public static func w(_ size: Size) -> TailwindStyle { TailwindStyle().w(size) }
  public static func h(_ size: Size) -> TailwindStyle { TailwindStyle().h(size) }

  // MARK: Colors

  public static func bg(_ color: Color, _ shade: Shade) -> TailwindStyle {
    TailwindStyle().bg(color, shade)
  }
  public static func borderColor(_ color: Color, _ shade: Shade) -> TailwindStyle {
    TailwindStyle().borderColor(color, shade)
  }

  // MARK: Typography

  public static func text(_ size: TextSize) -> TailwindStyle {
    TailwindStyle().text(size)
  }
  public static func text(_ color: Color, _ shade: Shade) -> TailwindStyle {
    TailwindStyle().text(color, shade)
  }
  public static func text(_ align: TextAlign) -> TailwindStyle {
    TailwindStyle().text(align)
  }
  public static func font(_ weight: FontWeight) -> TailwindStyle {
    TailwindStyle().font(weight)
  }

  // MARK: Borders & radius

  public static func border(_ width: Int) -> TailwindStyle {
    TailwindStyle().border(width)
  }
  public static func rounded(_ radius: Radius) -> TailwindStyle {
    TailwindStyle().rounded(radius)
  }

  // MARK: Responsive & state variants

  public static func sm(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().sm(style)
  }
  public static func md(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().md(style)
  }
  public static func lg(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().lg(style)
  }
  public static func xl(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().xl(style)
  }
  public static func xl2(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().xl2(style)
  }
  public static func hover(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().hover(style)
  }
  public static func focus(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().focus(style)
  }
  public static func active(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().active(style)
  }
  public static func disabled(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().disabled(style)
  }
  public static func groupHover(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().groupHover(style)
  }
  public static func dark(_ style: TailwindStyle) -> TailwindStyle {
    TailwindStyle().dark(style)
  }
}

/// Convenient alias for ``TailwindStyle`` so chains can read `TW.flex.gap(4)`.
///
/// The name is intentionally two characters — `TW` is the mandated public
/// spelling — so `type_name`'s minimum-length rule is disabled on this line.
public typealias TW = TailwindStyle  // swiftlint:disable:this type_name
