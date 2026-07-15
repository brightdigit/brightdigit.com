//
//  LenientISO8601DateTranscoder.swift
//  ButtondownKit
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
import OpenAPIRuntime

/// A ``DateTranscoder`` that decodes RFC-3339 / ISO-8601 timestamps whether or
/// not they carry fractional seconds.
///
/// The Buttondown API mixes both forms in a single response — e.g.
/// `creation_date` is `"2026-06-29T18:36:10.808726Z"` (fractional seconds) while
/// `publish_date` is `"2026-06-30T12:03:00Z"` (none). OpenAPIRuntime's default
/// ``ISO8601DateTranscoder`` is configured for exactly one shape and throws
/// `DecodingError.dataCorrupted` on the other, which makes every real listing
/// fail to decode. This transcoder tries the fractional-seconds parse first and
/// falls back to the whole-second parse, so both shapes decode.
///
/// Parsing goes through the value-type `Date.ISO8601FormatStyle`, which carries
/// no shared mutable state and is trivially `Sendable`.
public struct LenientISO8601DateTranscoder: DateTranscoder {
  /// Creates a new lenient transcoder.
  public init() {}

  /// Encodes the date as an ISO-8601 string with fractional seconds.
  public func encode(_ date: Date) throws -> String {
    date.formatted(Date.ISO8601FormatStyle(includingFractionalSeconds: true))
  }

  /// Decodes an ISO-8601 string, tolerating the presence or absence of
  /// fractional seconds.
  public func decode(_ dateString: String) throws -> Date {
    let styles = [
      Date.ISO8601FormatStyle(includingFractionalSeconds: true),
      Date.ISO8601FormatStyle(includingFractionalSeconds: false),
    ]
    for style in styles {
      if let date = try? style.parse(dateString) {
        return date
      }
    }
    throw DecodingError.dataCorrupted(
      .init(
        codingPath: [],
        debugDescription:
          "Expected date string to be ISO8601-formatted (with or without "
          + "fractional seconds): \(dateString)"
      )
    )
  }
}
