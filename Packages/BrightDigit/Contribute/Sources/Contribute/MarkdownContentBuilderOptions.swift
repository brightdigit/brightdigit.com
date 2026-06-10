//
//  MarkdownContentBuilderOptions.swift
//  Contribute
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

import Foundation

/// A type that represents the options that can be used when building markdown content.
public struct MarkdownContentBuilderOptions: OptionSet {
  public typealias RawValue = Int

  /// Specifies that any existing markdown content should be overwritten.
  internal static let shouldOverwriteExisting: Self = .init(rawValue: 1)

  /// Specifies that any missing previous markdown content should be included.
  internal static let includeMissingPrevious: Self = .init(rawValue: 2)

  public let rawValue: Int

  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
}

extension MarkdownContentBuilderOptions {
  /// Initializes a new  instance with the specified values.
  ///
  /// - Parameters:
  ///   - shouldOverwriteExisting: Specifies that any existing markdown content
  ///     should be overwritten.
  ///   - includeMissingPrevious: Specifies that any missing previous markdown content
  ///     should be included.
  public init(shouldOverwriteExisting: Bool, includeMissingPrevious: Bool) {
    self.init([
      includeMissingPrevious ? .includeMissingPrevious : .init(),
      shouldOverwriteExisting ? .shouldOverwriteExisting : .init(),
    ])
  }
}
