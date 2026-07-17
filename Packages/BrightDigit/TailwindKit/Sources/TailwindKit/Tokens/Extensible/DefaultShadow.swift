//
//  DefaultShadow.swift
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

/// The built-in Tailwind v4 box-shadow values.
public struct DefaultShadow: Shadow {
  /// `shadow-2xs`.
  fileprivate static let xs2Value = DefaultShadow("2xs")
  /// `shadow-xs`.
  fileprivate static let xsValue = DefaultShadow("xs")
  /// `shadow-sm`.
  fileprivate static let smValue = DefaultShadow("sm")
  /// `shadow-md`.
  fileprivate static let mdValue = DefaultShadow("md")
  /// `shadow-lg`.
  fileprivate static let lgValue = DefaultShadow("lg")
  /// `shadow-xl`.
  fileprivate static let xlValue = DefaultShadow("xl")
  /// `shadow-2xl`.
  fileprivate static let xl2Value = DefaultShadow("2xl")
  /// `shadow-none`.
  fileprivate static let noneValue = DefaultShadow("none")

  /// The rendered fragment, e.g. `"lg"`.
  public let token: String

  internal init(_ token: String) {
    self.token = token
  }
}

extension Shadow where Self == DefaultShadow {
  // swiftlint:disable identifier_name
  /// `shadow-2xs`.
  public static var xs2: DefaultShadow { .xs2Value }
  /// `shadow-xs`.
  public static var xs: DefaultShadow { .xsValue }
  /// `shadow-sm`.
  public static var sm: DefaultShadow { .smValue }
  /// `shadow-md`.
  public static var md: DefaultShadow { .mdValue }
  /// `shadow-lg`.
  public static var lg: DefaultShadow { .lgValue }
  /// `shadow-xl`.
  public static var xl: DefaultShadow { .xlValue }
  // swiftlint:enable identifier_name
  /// `shadow-2xl`.
  public static var xl2: DefaultShadow { .xl2Value }
  /// `shadow-none`.
  public static var none: DefaultShadow { .noneValue }
}
