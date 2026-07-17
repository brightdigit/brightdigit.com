//
//  DefaultMaxWidth.swift
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

/// The built-in `max-width` scale values plus `full`/`none`.
public struct DefaultMaxWidth: MaxWidth {
  /// `max-w-sm`.
  fileprivate static let smValue = DefaultMaxWidth("sm")
  /// `max-w-lg`.
  fileprivate static let lgValue = DefaultMaxWidth("lg")
  /// `max-w-2xl`.
  fileprivate static let xl2Value = DefaultMaxWidth("2xl")
  /// `max-w-4xl`.
  fileprivate static let xl4Value = DefaultMaxWidth("4xl")
  /// `max-w-full`.
  fileprivate static let fullValue = DefaultMaxWidth("full")
  /// `max-w-none`.
  fileprivate static let noneValue = DefaultMaxWidth("none")

  /// The rendered fragment, e.g. `"4xl"`, `"full"`.
  public let token: String

  internal init(_ token: String) {
    self.token = token
  }
}

extension MaxWidth where Self == DefaultMaxWidth {
  // swiftlint:disable identifier_name
  /// `max-w-sm`.
  public static var sm: DefaultMaxWidth { .smValue }
  /// `max-w-lg`.
  public static var lg: DefaultMaxWidth { .lgValue }
  // swiftlint:enable identifier_name
  /// `max-w-2xl`.
  public static var xl2: DefaultMaxWidth { .xl2Value }
  /// `max-w-4xl`.
  public static var xl4: DefaultMaxWidth { .xl4Value }
  /// `max-w-full`.
  public static var full: DefaultMaxWidth { .fullValue }
  /// `max-w-none`.
  public static var none: DefaultMaxWidth { .noneValue }

  /// A documented arbitrary max-width, e.g. `.arbitrary("48rem")` →
  /// `max-w-[48rem]`. Spaces become underscores.
  public static func arbitrary(_ value: String) -> DefaultMaxWidth {
    .init("[\(value.replacingOccurrences(of: " ", with: "_"))]")
  }
}
