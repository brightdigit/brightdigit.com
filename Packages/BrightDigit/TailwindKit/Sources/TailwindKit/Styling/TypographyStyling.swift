//
//  TypographyStyling.swift
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

/// Typography utilities — font size/weight/style, text decoration & transform,
/// alignment, tracking, and line height.
///
/// A capability protocol witnessed against the ``TailwindStyleProtocol`` seam;
/// ``TailwindStyle`` conforms to it. The color-based `text(_:_:)` overloads live
/// in ``ColorStyling``; here `text(_:)` covers size and alignment. See
/// ``TailwindStyleProtocol`` for the architecture rationale.
public protocol TypographyStyling {
  /// `text-white`.
  var textWhite: Self { get }
  /// `text-black`.
  var textBlack: Self { get }
  /// `italic`.
  var italic: Self { get }
  /// `underline`.
  var underline: Self { get }
  /// `no-underline`.
  var noUnderline: Self { get }
  /// `uppercase`.
  var uppercase: Self { get }
  /// `lowercase`.
  var lowercase: Self { get }
  /// `capitalize`.
  var capitalize: Self { get }
  /// `whitespace-pre-wrap`.
  var whitespacePreWrap: Self { get }
  /// `leading-none` (`line-height: 1`).
  var leadingNone: Self { get }

  /// `text-<size>`, e.g. `.text(.lg)`.
  func text(_ size: some TextSize) -> Self
  /// `text-<align>`, e.g. `.text(.center)`.
  func text(_ align: TextAlign) -> Self
  /// `font-<weight>`, e.g. `.font(.medium)`.
  func font(_ weight: some FontWeight) -> Self
  /// `align-<value>`, e.g. `.align(.middle)` → `align-middle`.
  func align(_ value: VerticalAlign) -> Self
  /// `tracking-<value>`, e.g. `.tracking(.tight)`.
  func tracking(_ value: some Tracking) -> Self
  /// `leading-<n>` (numeric line-height), e.g. `.leading(6)`.
  func leading(_ value: Int) -> Self
}

extension TypographyStyling where Self: TailwindStyleProtocol {
  // MARK: Bare

  /// `text-white`.
  public var textWhite: Self {
    appending(TailwindStyle.DefaultTailwindClass("text-white"))
  }
  /// `text-black`.
  public var textBlack: Self {
    appending(TailwindStyle.DefaultTailwindClass("text-black"))
  }
  /// `italic`.
  public var italic: Self { appending(TailwindStyle.DefaultTailwindClass("italic")) }
  /// `underline`.
  public var underline: Self { appending(TailwindStyle.DefaultTailwindClass("underline")) }
  /// `no-underline`.
  public var noUnderline: Self {
    appending(TailwindStyle.DefaultTailwindClass("no-underline"))
  }
  /// `uppercase`.
  public var uppercase: Self { appending(TailwindStyle.DefaultTailwindClass("uppercase")) }
  /// `lowercase`.
  public var lowercase: Self { appending(TailwindStyle.DefaultTailwindClass("lowercase")) }
  /// `capitalize`.
  public var capitalize: Self {
    appending(TailwindStyle.DefaultTailwindClass("capitalize"))
  }
  /// `whitespace-pre-wrap`.
  public var whitespacePreWrap: Self {
    appending(TailwindStyle.DefaultTailwindClass("whitespace-pre-wrap"))
  }
  /// `leading-none` (`line-height: 1`).
  public var leadingNone: Self {
    appending(TailwindStyle.DefaultTailwindClass("leading-none"))
  }

  // MARK: Parameterized

  /// `text-<size>`, e.g. `.text(.lg)`.
  public func text(_ size: some TextSize) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("text-\(size.token)"))
  }
  /// `text-<align>`, e.g. `.text(.center)`.
  public func text(_ align: TextAlign) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("text-\(align.token)"))
  }
  /// `font-<weight>`, e.g. `.font(.medium)`.
  public func font(_ weight: some FontWeight) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("font-\(weight.token)"))
  }
  /// `align-<value>`, e.g. `.align(.middle)` → `align-middle`.
  public func align(_ value: VerticalAlign) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("align-\(value.token)"))
  }
  /// `tracking-<value>`, e.g. `.tracking(.tight)`.
  public func tracking(_ value: some Tracking) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("tracking-\(value.token)"))
  }
  /// `leading-<n>` (numeric line-height), e.g. `.leading(6)`.
  public func leading(_ value: Int) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("leading-\(value)"))
  }
}

extension TailwindStyle: TypographyStyling {}

// Static mirrors so a typography utility can start a chain with a leading dot.
extension TailwindStyle {
  /// `text-white`.
  public static var textWhite: TailwindStyle { TailwindStyle().textWhite }
  /// `text-black`.
  public static var textBlack: TailwindStyle { TailwindStyle().textBlack }
  /// `italic`.
  public static var italic: TailwindStyle { TailwindStyle().italic }
  /// `underline`.
  public static var underline: TailwindStyle { TailwindStyle().underline }
  /// `no-underline`.
  public static var noUnderline: TailwindStyle { TailwindStyle().noUnderline }
  /// `uppercase`.
  public static var uppercase: TailwindStyle { TailwindStyle().uppercase }
  /// `lowercase`.
  public static var lowercase: TailwindStyle { TailwindStyle().lowercase }
  /// `capitalize`.
  public static var capitalize: TailwindStyle { TailwindStyle().capitalize }
  /// `whitespace-pre-wrap`.
  public static var whitespacePreWrap: TailwindStyle { TailwindStyle().whitespacePreWrap }
  /// `leading-none`.
  public static var leadingNone: TailwindStyle { TailwindStyle().leadingNone }
}

extension TailwindStyle {
  /// `text-<size>`.
  public static func text(_ size: some TextSize) -> TailwindStyle { TailwindStyle().text(size) }
  /// `text-<align>`.
  public static func text(_ align: TextAlign) -> TailwindStyle { TailwindStyle().text(align) }
  /// `font-<weight>`.
  public static func font(_ weight: some FontWeight) -> TailwindStyle {
    TailwindStyle().font(weight)
  }
  /// `align-<value>`.
  public static func align(_ value: VerticalAlign) -> TailwindStyle {
    TailwindStyle().align(value)
  }
  /// `tracking-<value>`.
  public static func tracking(_ value: some Tracking) -> TailwindStyle {
    TailwindStyle().tracking(value)
  }
  /// `leading-<n>`.
  public static func leading(_ value: Int) -> TailwindStyle { TailwindStyle().leading(value) }
}
