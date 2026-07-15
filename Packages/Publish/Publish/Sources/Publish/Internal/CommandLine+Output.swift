/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

extension CommandLine {
  internal enum OutputKind {
    case info
    case warning
    case error
    case success
  }

  internal static func output(_ string: String, as kind: OutputKind) {
    var string = string + "\n"

    if let emoji = kind.emoji {
      string = "\(emoji) \(string)"
    }

    try? kind.target.write(contentsOf: Data(string.utf8))
  }
}

extension CommandLine.OutputKind {
  fileprivate var emoji: Character? {
    switch self {
    case .info:
      return nil
    case .warning:
      return "⚠️"
    case .error:
      return "❌"
    case .success:
      return "✅"
    }
  }

  fileprivate var target: FileHandle {
    switch self {
    case .info, .warning, .success:
      return .standardOutput
    case .error:
      return .standardOutput
    }
  }
}
