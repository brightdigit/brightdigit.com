/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*
*  #40: Ink's leading `---` front-matter block is not part of CommonMark, so
*  swift-markdown does not parse it. This retained pre-pass strips and decodes the
*  front matter (line-based, replacing the old `Reader` implementation) before the
*  body is handed to swift-markdown. `.metadataKeys`/`.metadataValues` modifiers are
*  applied here exactly as before.
*/

internal struct Metadata {
  internal var values = [String: String]()

  // Inherently branchy: front-matter line scanner.
  // swiftlint:disable cyclomatic_complexity
  /// Parse a leading `---` … `---` metadata block from `lines`, returning the parsed
  /// metadata and the index of the first body line. Returns `nil` if the input does
  /// not begin with a valid front-matter block.
  internal static func parse(lines: [Substring]) -> (metadata: Metadata, bodyLineIndex: Int)? {
    // Find the first non-empty line; it must be exactly a `---` fence.
    var index = 0
    while index < lines.count, lines[index].allSatisfy(\.isWhitespace) {
      index += 1
    }

    guard index < lines.count, isFence(lines[index]) else {
      return nil
    }
    index += 1

    var metadata = Metadata()
    var lastKey: String?

    while index < lines.count {
      let line = lines[index]
      index += 1

      if isFence(line) {
        return (metadata, index)
      }

      if line.allSatisfy(\.isWhitespace) {
        continue
      }

      if let separatorIndex = line.firstIndex(of: ":") {
        let key = trim(line[..<separatorIndex])
        let value = trim(line[line.index(after: separatorIndex)...])

        if !value.isEmpty {
          metadata.values[key] = value
          lastKey = key
        }
      } else if let lastKey {
        // Continuation line for the previous value.
        metadata.values[lastKey]?.append(" " + trim(line))
      }
    }

    // No closing fence: not valid front matter.
    return nil
  }
  // swiftlint:enable cyclomatic_complexity

  internal func applyingModifiers(_ modifiers: ModifierCollection) -> Self {
    var modified = self

    modifiers.applyModifiers(for: .metadataKeys) { modifier in
      for (key, value) in modified.values {
        let newKey = modifier.closure((key, Substring(key)))
        modified.values[key] = nil
        modified.values[newKey] = value
      }
    }

    modifiers.applyModifiers(for: .metadataValues) { modifier in
      modified.values = modified.values.mapValues { value in
        modifier.closure((value, Substring(value)))
      }
    }

    return modified
  }
}

extension Metadata {
  fileprivate static func isFence(_ line: Substring) -> Bool {
    let trimmed = trim(line)
    return trimmed.count == 3 && trimmed.allSatisfy { $0 == "-" }
  }

  fileprivate static func trim(_ string: Substring) -> String {
    var trimmed = string
    while trimmed.first?.isWhitespace == true { trimmed = trimmed.dropFirst() }
    while trimmed.last?.isWhitespace == true { trimmed = trimmed.dropLast() }
    return String(trimmed)
  }
}
