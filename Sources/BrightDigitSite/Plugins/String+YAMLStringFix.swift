//
//  String+YAMLStringFix.swift
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
import Publish

extension String {
  private static let escUnicodeRegex: NSRegularExpression = {
    do {
      return try NSRegularExpression(
        pattern: "\\\\U([0-9a-f]{8})",
        options: [.caseInsensitive]
      )
    } catch {
      preconditionFailure("Invalid escUnicodeRegex pattern: \(error)")
    }
  }()

  public func fixEmojiis() -> String {
    let allMatches = Self.escUnicodeRegex.matches(
      in: self,
      range: .init(location: 0, length: count)
    )
    let matches = allMatches.reversed()
    var result = self
    for match in matches {
      guard let range = Range(match.range, in: result) else {
        continue
      }
      guard let codeRange = Range(match.range(at: 1), in: result) else {
        continue
      }
      let codeString = self[codeRange]
      guard let value = Int(codeString, radix: 16) else {
        continue
      }
      guard let scalar = UnicodeScalar(value) else {
        continue
      }
      result.replaceSubrange(range, with: String(scalar))
    }
    return result
  }
}

extension PublishingStep {
  public static var yamlStringFix: Self {
    .step(named: "Dequoting YAML Metadata") { context in
      context.mutateAllSections { section in
        section.mutateItems { item in
          item.title = item.title.fixEmojiis().dequote()
          item.description = item.description.fixEmojiis().dequote()
        }
      }
    }
  }
}
