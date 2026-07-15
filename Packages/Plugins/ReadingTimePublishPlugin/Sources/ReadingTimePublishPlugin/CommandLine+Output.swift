/**
 * CommandLine extension taken from Publish itself.
 * https://github.com/JohnSundell/Publish/blob/master/Sources/Publish/Internal/CommandLine%2BOutput.swift
 */

import Foundation
import Synchronization

// A replaceable output hook (tests swap it to capture console output). Stored
// in a Mutex so the global is concurrency-safe.
let output = Mutex<@Sendable (String, OutputKind) -> Void>({ string, kind in
    var string = string + "\n"

    if let emoji = kind.emoji {
        string = "\(emoji) \(string)"
    }

    try? kind.target.write(contentsOf: Data(string.utf8))
})

enum OutputKind {
    case info
    case warning
    case error
    case success
}

private extension OutputKind {
    var emoji: Character? {
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

    // `FileHandle` rather than the C `stdout` global, which on Linux (glibc) is
    // a mutable `var` and not concurrency-safe under Swift 6.
    var target: FileHandle {
        switch self {
        case .info, .warning, .success:
            return .standardOutput
        case .error:
            return .standardOutput
        }
    }
}
