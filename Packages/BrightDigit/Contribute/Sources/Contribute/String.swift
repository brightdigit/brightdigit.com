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

    return String(trimmedString[startIndex ..< endIndex])
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

  #if os(Linux)
    private func convertedToSlugBackCompat() -> String? {
      // On Linux StringTransform doesn't exist and CFStringTransform causes all sorts
      // of problems because of bridging issues using CFMutableString – d'oh.
      // So we're going to do the only thing possible: dump to ASCII and hope for the best
      if let data = data(using: .ascii, allowLossyConversion: true) {
        if let str = String(data: data, encoding: .ascii) {
          let urlComponents = str
            .lowercased()
            .components(separatedBy: String.slugSafeCharacters.inverted)

          return urlComponents.filter { $0.isEmpty == false }.joined(separator: "-")
        }
      }

      // still here? Something went disastrously wrong!
      return nil
    }
  #endif

  private func convertedToSlug() -> String? {
    #if os(Linux)
      return convertedToSlugBackCompat()
    #else
      guard let latin = applyingTransform(String.latinStringTransform, reverse: false)
      else {
        return nil
      }

      let urlComponents = latin
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
