//
//  CommandError.swift
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

/// Errors surfaced while resolving and running `brightdigitwg` commands via the
/// swift-configuration stack (issue #44).
///
/// Shared across the migrated ConfigKeyKit commands (`publish`, `import podcast`,
/// `import mailchimp`, `import wordpress`). Each command resolves its options
/// through a ``Configuration/ConfigReader`` and throws one of these cases when a
/// required option is missing or a supplied value cannot be parsed.
public enum CommandError: Error, CustomStringConvertible {
  /// A required option was not supplied via CLI or environment.
  case missingRequiredOption(String)
  /// A supplied option value could not be parsed into the expected type.
  case invalidValue(option: String, value: String)
  /// A supplied value was expected to be a URL but could not be parsed.
  case invalidURL(String)

  public var description: String {
    switch self {
    case let .missingRequiredOption(name):
      return "Missing required option: \(name)"
    case let .invalidValue(option, value):
      return "Invalid value for \(option): \(value)"
    case let .invalidURL(value):
      return "Invalid URL: \(value)"
    }
  }
}
