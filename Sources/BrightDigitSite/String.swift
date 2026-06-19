//
//  String.swift
//  BrightDigit
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

extension String {
  private static let quotes = ["\"", "'"]

  private static let slugSafeCharacters = CharacterSet(
    charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"
  )

  internal func dequote() -> String {
    let trimmedString = trimmingCharacters(in: .whitespacesAndNewlines)
    guard let first = trimmedString.first.map(String.init),
      let last = trimmedString.last.map(String.init), trimmedString.count > 1,
      last == first
    else {
      return trimmedString
    }

    guard Self.quotes.contains(first) else {
      return trimmedString
    }
    let startIndex = trimmedString.index(after: trimmedString.startIndex)
    let endIndex = trimmedString.index(before: trimmedString.endIndex)

    return String(trimmedString[startIndex..<endIndex])
  }

  private func convertedToSlugBackCompat() -> String? {
    // On Linux StringTransform doesn't exist and CFStringTransform causes all sorts
    // of problems because of bridging issues using CFMutableString – d'oh.
    // So we're going to do the only thing possible: dump to ASCII and hope for the best
    if let data = data(using: .ascii, allowLossyConversion: true) {
      if let str = String(data: data, encoding: .ascii) {
        let urlComponents = str.lowercased().components(
          separatedBy: String.slugSafeCharacters.inverted
        )
        return urlComponents.filter { !$0.isEmpty }.joined(separator: "-")
      }
    }

    // still here? Something went disastrously wrong!
    return nil
  }

  public func convertedToSlug() -> String {
    var result: String?

    #if os(Linux)
      result = convertedToSlugBackCompat()
    #else
      if #available(OSX 10.11, *) {
        if let latin = self.applyingTransform(
          StringTransform("Any-Latin; Latin-ASCII; Lower;"),
          reverse: false
        ) {
          let urlComponents = latin.components(
            separatedBy: String.slugSafeCharacters.inverted
          )
          result = urlComponents.filter { !$0.isEmpty }.joined(separator: "-")
        }
      } else {
        result = convertedToSlugBackCompat()
      }
    #endif

    guard var result = result, !result.isEmpty else {
      return self
    }

    var previous = result

    repeat {
      previous = result
      result = previous.replacingOccurrences(of: "--", with: "-")
    } while previous != result

    return result
  }
}
