//
//  String.swift
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

extension String {
  private static let quotes = ["\"", "'"]

  /// The set of characters that are safe for use in slugs.
  private static let slugSafeCharacters = CharacterSet(
    charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"
  )

  /// Used to convert a string to a slug that is safe for use on macOS 10.11 and later.
  private static let latinStringTransform = StringTransform(
    "Any-Latin; Latin-ASCII; Lower;"
  )

  /// Fixes a unicode escape sequence in the string.
  ///
  /// - Returns: The string with the unicode escape sequence fixed.
  public func fixUnicodeEscape() -> String {
    replacingOccurrences(of: "’", with: "'")
  }

  /// Removes any quotes from the string.
  ///
  /// - Returns: The string without any quotes.
  public func dequote() -> String {
    let trimmedString = trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      let first = trimmedString.first.map(String.init),
      let last = trimmedString.last.map(String.init),
      trimmedString.count > 1,
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

  /// Pads the left side of the string with the specified character
  /// up to the specified width.
  ///
  /// - Parameters:
  ///   - totalWidth: The desired width of the string.
  ///   - byString: The character to pad the string with.
  /// - Returns: The padded string.
  public func padLeft(totalWidth: Int, byString: String) -> String {
    let toPad = totalWidth - count
    if toPad < 1 {
      return self
    }

    return "".padding(toLength: toPad, withPad: byString, startingAt: 0) + self
  }

  #if !canImport(Darwin)
    private func convertedToSlugBackCompat() -> String? {
      // `StringTransform` ("Any-Latin; Latin-ASCII; Lower") is unavailable on
      // non-Apple platforms (Linux, Windows, Android, wasm). Fold diacritics to
      // their ASCII base (e.g. "ü" -> "u") so the result matches the Darwin
      // `latinStringTransform` output for Latin titles — keeping slugs identical
      // across platforms — then keep only slug-safe characters.
      //
      // The previous lossy `.ascii` conversion was unreliable: for some strings
      // it returned nil, so `slugify()` silently fell back to the un-slugified
      // title (e.g. "120% Likely with Cihat Gündüz" was used verbatim as a
      // filename instead of "120-likely-with-cihat-gunduz").
      let folded = folding(
        options: .diacriticInsensitive,
        locale: Locale(identifier: "en_US_POSIX")
      )
      let urlComponents =
        folded
        .lowercased()
        .components(separatedBy: String.slugSafeCharacters.inverted)

      return urlComponents.filter { $0.isEmpty == false }.joined(separator: "-")
    }
  #endif

  private func convertedToSlug() -> String? {
    #if !canImport(Darwin)
      return convertedToSlugBackCompat()
    #else
      guard let latin = applyingTransform(String.latinStringTransform, reverse: false)
      else {
        return nil
      }

      let urlComponents =
        latin
        .components(separatedBy: String.slugSafeCharacters.inverted)

      return urlComponents.filter { $0.isEmpty == false }.joined(separator: "-")
    #endif
  }

  /// Converts the string to a slug.
  ///
  /// - Returns: The string converted to a slug.
  public func slugify() -> String {
    guard var result = convertedToSlug(), result.isEmpty == false else {
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
