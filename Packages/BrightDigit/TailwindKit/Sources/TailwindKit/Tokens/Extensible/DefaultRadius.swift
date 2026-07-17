//
//  DefaultRadius.swift
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

/// The built-in Tailwind v4 border-radius values.
public struct DefaultRadius: Radius {
  /// `rounded-none`.
  fileprivate static let noneValue = DefaultRadius("none")
  /// `rounded-xs`.
  fileprivate static let xsValue = DefaultRadius("xs")
  /// `rounded-sm`.
  fileprivate static let smValue = DefaultRadius("sm")
  /// Bare `rounded` (empty token).
  fileprivate static let baseValue = DefaultRadius("")
  /// `rounded-md`.
  fileprivate static let mdValue = DefaultRadius("md")
  /// `rounded-lg`.
  fileprivate static let lgValue = DefaultRadius("lg")
  /// `rounded-xl`.
  fileprivate static let xlValue = DefaultRadius("xl")
  /// `rounded-2xl`.
  fileprivate static let xl2Value = DefaultRadius("2xl")
  /// `rounded-3xl`.
  fileprivate static let xl3Value = DefaultRadius("3xl")
  /// `rounded-full`.
  fileprivate static let fullValue = DefaultRadius("full")

  /// The rendered fragment, e.g. `"lg"`; `""` for the bare `rounded`.
  public let token: String

  internal init(_ token: String) {
    self.token = token
  }
}

extension Radius where Self == DefaultRadius {
  // swiftlint:disable identifier_name
  /// `rounded-none`.
  public static var none: DefaultRadius { .noneValue }
  /// `rounded-xs`.
  public static var xs: DefaultRadius { .xsValue }
  /// `rounded-sm`.
  public static var sm: DefaultRadius { .smValue }
  /// Bare `rounded` (empty token).
  public static var base: DefaultRadius { .baseValue }
  /// `rounded-md`.
  public static var md: DefaultRadius { .mdValue }
  /// `rounded-lg`.
  public static var lg: DefaultRadius { .lgValue }
  /// `rounded-xl`.
  public static var xl: DefaultRadius { .xlValue }
  // swiftlint:enable identifier_name
  /// `rounded-2xl`.
  public static var xl2: DefaultRadius { .xl2Value }
  /// `rounded-3xl`.
  public static var xl3: DefaultRadius { .xl3Value }
  /// `rounded-full`.
  public static var full: DefaultRadius { .fullValue }
}
