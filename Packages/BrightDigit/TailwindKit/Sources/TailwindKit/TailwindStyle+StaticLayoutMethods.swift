//
//  TailwindStyle+StaticLayoutMethods.swift
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
  // MARK: Position offsets & z-index

  /// `top-<n>`.
  public static func top(_ amount: Spacing) -> TailwindStyle { TailwindStyle().top(amount) }
  /// `right-<n>`.
  public static func right(_ amount: Spacing) -> TailwindStyle { TailwindStyle().right(amount) }
  /// `bottom-<n>`.
  public static func bottom(_ amount: Spacing) -> TailwindStyle { TailwindStyle().bottom(amount) }
  /// `left-<n>`.
  public static func left(_ amount: Spacing) -> TailwindStyle { TailwindStyle().left(amount) }
  /// `inset-<n>`.
  public static func inset(_ amount: Spacing) -> TailwindStyle { TailwindStyle().inset(amount) }
  /// `z-<n>`.
  public static func z(_ index: Int) -> TailwindStyle { TailwindStyle().z(index) }

  // MARK: Sizing extras

  /// `max-w-<size>`.
  public static func maxW(_ size: MaxWidth) -> TailwindStyle { TailwindStyle().maxW(size) }
  /// `max-h-<size>`.
  public static func maxH(_ size: Size) -> TailwindStyle { TailwindStyle().maxH(size) }

  // MARK: Alignment extras

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
  public static func spaceX(_ amount: Spacing) -> TailwindStyle {
    TailwindStyle().spaceX(amount)
  }
  /// `space-y-<n>`.
  public static func spaceY(_ amount: Spacing) -> TailwindStyle {
    TailwindStyle().spaceY(amount)
  }

  // MARK: Borders extras

  /// `border-<side>-<n>`.
  public static func border(_ side: BorderSide, _ width: Int) -> TailwindStyle {
    TailwindStyle().border(side, width)
  }

  // MARK: Typography extras

  /// `align-<value>`.
  public static func align(_ value: VerticalAlign) -> TailwindStyle {
    TailwindStyle().align(value)
  }
  /// `tracking-<value>`.
  public static func tracking(_ value: Tracking) -> TailwindStyle {
    TailwindStyle().tracking(value)
  }
  /// `leading-<n>`.
  public static func leading(_ value: Int) -> TailwindStyle { TailwindStyle().leading(value) }

  // MARK: Effects

  /// `shadow-<value>`.
  public static func shadow(_ shadow: Shadow) -> TailwindStyle { TailwindStyle().shadow(shadow) }
  /// `drop-shadow-<value>`.
  public static func dropShadow(_ shadow: DropShadow) -> TailwindStyle {
    TailwindStyle().dropShadow(shadow)
  }
  /// `ring-<n>`.
  public static func ring(_ width: Int) -> TailwindStyle { TailwindStyle().ring(width) }
  /// `opacity-<n>`.
  public static func opacity(_ value: Int) -> TailwindStyle { TailwindStyle().opacity(value) }
  /// `object-<fit>`.
  public static func object(_ fit: ObjectFit) -> TailwindStyle { TailwindStyle().object(fit) }

  // MARK: Transitions & filters

  /// `duration-<ms>`.
  public static func duration(_ milliseconds: Int) -> TailwindStyle {
    TailwindStyle().duration(milliseconds)
  }
  /// `ease-<value>`.
  public static func ease(_ ease: Ease) -> TailwindStyle { TailwindStyle().ease(ease) }
  /// `backdrop-blur-<size>`.
  public static func backdropBlur(_ radius: Radius) -> TailwindStyle {
    TailwindStyle().backdropBlur(radius)
  }
  /// `backdrop-brightness-<n>`.
  public static func backdropBrightness(_ value: Int) -> TailwindStyle {
    TailwindStyle().backdropBrightness(value)
  }
  /// `hue-rotate-<deg>`.
  public static func hueRotate(_ degrees: Int) -> TailwindStyle {
    TailwindStyle().hueRotate(degrees)
  }
}
