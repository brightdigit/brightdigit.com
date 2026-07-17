//
//  DefaultTextSize.swift
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

/// The built-in Tailwind v4 font sizes.
public struct DefaultTextSize: TextSize {
  /// `text-xs`.
  fileprivate static let xsValue = DefaultTextSize("xs")
  /// `text-sm`.
  fileprivate static let smValue = DefaultTextSize("sm")
  /// `text-base`.
  fileprivate static let baseValue = DefaultTextSize("base")
  /// `text-lg`.
  fileprivate static let lgValue = DefaultTextSize("lg")
  /// `text-xl`.
  fileprivate static let xlValue = DefaultTextSize("xl")
  /// `text-2xl`.
  fileprivate static let xl2Value = DefaultTextSize("2xl")
  /// `text-3xl`.
  fileprivate static let xl3Value = DefaultTextSize("3xl")
  /// `text-4xl`.
  fileprivate static let xl4Value = DefaultTextSize("4xl")
  /// `text-5xl`.
  fileprivate static let xl5Value = DefaultTextSize("5xl")
  /// `text-6xl`.
  fileprivate static let xl6Value = DefaultTextSize("6xl")
  /// `text-7xl`.
  fileprivate static let xl7Value = DefaultTextSize("7xl")
  /// `text-8xl`.
  fileprivate static let xl8Value = DefaultTextSize("8xl")
  /// `text-9xl`.
  fileprivate static let xl9Value = DefaultTextSize("9xl")

  /// The rendered fragment, e.g. `"lg"`, `"2xl"`.
  public let token: String

  internal init(_ token: String) {
    self.token = token
  }
}

extension TextSize where Self == DefaultTextSize {
  // swiftlint:disable identifier_name
  /// `text-xs`.
  public static var xs: DefaultTextSize { .xsValue }
  /// `text-sm`.
  public static var sm: DefaultTextSize { .smValue }
  /// `text-base`.
  public static var base: DefaultTextSize { .baseValue }
  /// `text-lg`.
  public static var lg: DefaultTextSize { .lgValue }
  /// `text-xl`.
  public static var xl: DefaultTextSize { .xlValue }
  // swiftlint:enable identifier_name
  /// `text-2xl`.
  public static var xl2: DefaultTextSize { .xl2Value }
  /// `text-3xl`.
  public static var xl3: DefaultTextSize { .xl3Value }
  /// `text-4xl`.
  public static var xl4: DefaultTextSize { .xl4Value }
  /// `text-5xl`.
  public static var xl5: DefaultTextSize { .xl5Value }
  /// `text-6xl`.
  public static var xl6: DefaultTextSize { .xl6Value }
  /// `text-7xl`.
  public static var xl7: DefaultTextSize { .xl7Value }
  /// `text-8xl`.
  public static var xl8: DefaultTextSize { .xl8Value }
  /// `text-9xl`.
  public static var xl9: DefaultTextSize { .xl9Value }
}
