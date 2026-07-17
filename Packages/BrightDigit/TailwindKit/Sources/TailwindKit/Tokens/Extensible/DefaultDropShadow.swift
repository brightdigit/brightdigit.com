//
//  DefaultDropShadow.swift
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

/// The built-in Tailwind v4 drop-shadow values.
public struct DefaultDropShadow: DropShadow {
  /// `drop-shadow-xs`.
  fileprivate static let xsValue = DefaultDropShadow("xs")
  /// `drop-shadow-sm`.
  fileprivate static let smValue = DefaultDropShadow("sm")
  /// `drop-shadow-md`.
  fileprivate static let mdValue = DefaultDropShadow("md")
  /// `drop-shadow-lg`.
  fileprivate static let lgValue = DefaultDropShadow("lg")
  /// `drop-shadow-xl`.
  fileprivate static let xlValue = DefaultDropShadow("xl")
  /// `drop-shadow-2xl`.
  fileprivate static let xl2Value = DefaultDropShadow("2xl")
  /// `drop-shadow-none`.
  fileprivate static let noneValue = DefaultDropShadow("none")

  /// The rendered fragment, e.g. `"xl"`.
  public let token: String

  internal init(_ token: String) {
    self.token = token
  }
}

extension DropShadow where Self == DefaultDropShadow {
  // swiftlint:disable identifier_name
  /// `drop-shadow-xs`.
  public static var xs: DefaultDropShadow { .xsValue }
  /// `drop-shadow-sm`.
  public static var sm: DefaultDropShadow { .smValue }
  /// `drop-shadow-md`.
  public static var md: DefaultDropShadow { .mdValue }
  /// `drop-shadow-lg`.
  public static var lg: DefaultDropShadow { .lgValue }
  /// `drop-shadow-xl`.
  public static var xl: DefaultDropShadow { .xlValue }
  // swiftlint:enable identifier_name
  /// `drop-shadow-2xl`.
  public static var xl2: DefaultDropShadow { .xl2Value }
  /// `drop-shadow-none`.
  public static var none: DefaultDropShadow { .noneValue }
}
