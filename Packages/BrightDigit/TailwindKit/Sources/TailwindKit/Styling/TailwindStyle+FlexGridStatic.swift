//
//  TailwindStyle+FlexGridStatic.swift
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
  /// `flex-wrap`.
  public static var flexWrap: TailwindStyle { TailwindStyle().flexWrap }
  /// `grow`.
  public static var grow: TailwindStyle { TailwindStyle().grow }
  /// `shrink`.
  public static var shrink: TailwindStyle { TailwindStyle().shrink }
  /// `grow-0`.
  public static var grow0: TailwindStyle { TailwindStyle().grow0 }
  /// `shrink-0`.
  public static var shrink0: TailwindStyle { TailwindStyle().shrink0 }
  /// `gap` (bare).
  public static var gap: TailwindStyle { TailwindStyle().gap }
}

extension TailwindStyle {
  /// `items-<align>`.
  public static func items(_ align: Align) -> TailwindStyle { TailwindStyle().items(align) }
  /// `justify-<value>`.
  public static func justify(_ value: Justify) -> TailwindStyle { TailwindStyle().justify(value) }
  /// `grid-cols-<n>`.
  public static func gridCols(_ count: Int) -> TailwindStyle { TailwindStyle().gridCols(count) }
  /// `gap-<n>`.
  public static func gap(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().gap(amount) }
  /// `gap-x-<n>`.
  public static func gapX(_ amount: DefaultSpacing) -> TailwindStyle {
    TailwindStyle().gapX(amount)
  }
  /// `gap-y-<n>`.
  public static func gapY(_ amount: DefaultSpacing) -> TailwindStyle {
    TailwindStyle().gapY(amount)
  }
  /// `flex-<value>`.
  public static func flex(_ value: Flex) -> TailwindStyle { TailwindStyle().flex(value) }
  /// `flex-<direction>`.
  public static func flexDirection(_ value: FlexDirection) -> TailwindStyle {
    TailwindStyle().flexDirection(value)
  }
  /// `self-<align>`.
  public static func selfAlign(_ align: Align) -> TailwindStyle {
    TailwindStyle().selfAlign(align)
  }
  /// `justify-items-<value>`.
  public static func justifyItems(_ align: Align) -> TailwindStyle {
    TailwindStyle().justifyItems(align)
  }
  /// `justify-self-<value>`.
  public static func justifySelf(_ align: Align) -> TailwindStyle {
    TailwindStyle().justifySelf(align)
  }
  /// `content-<value>`.
  public static func content(_ value: Justify) -> TailwindStyle {
    TailwindStyle().content(value)
  }
  /// `place-items-<align>`.
  public static func placeItems(_ align: Align) -> TailwindStyle {
    TailwindStyle().placeItems(align)
  }
  /// `place-self-<align>`.
  public static func placeSelf(_ align: Align) -> TailwindStyle {
    TailwindStyle().placeSelf(align)
  }
  /// `space-x-<n>`.
  public static func spaceX(_ amount: DefaultSpacing) -> TailwindStyle {
    TailwindStyle().spaceX(amount)
  }
  /// `space-y-<n>`.
  public static func spaceY(_ amount: DefaultSpacing) -> TailwindStyle {
    TailwindStyle().spaceY(amount)
  }
}
