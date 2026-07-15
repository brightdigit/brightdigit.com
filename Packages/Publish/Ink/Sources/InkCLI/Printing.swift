/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

internal func printError(_ error: CustomStringConvertible) {
    // Write via FileHandle rather than the C `stderr` global, which on Linux
    // (glibc) is a mutable `var` and not concurrency-safe under Swift 6.
    try? FileHandle.standardError.write(contentsOf: Data("\(error)\n".utf8))
}

internal func printUsageMessage() {
    printError(usageMessage)
}

private let usageMessage = """
Usage:  ink [file | -m markdown]
Options:
  --markdown, -m    Parse a markdown string directly
  --help, -h        Print usage information
"""

internal let helpMessage = """
Ink: Markdown -> HTML converter
-------------------------------
\(usageMessage)

Ink takes Markdown formatted text as input,
and returns HTML as output. If called without
arguments, it will read from STDIN. If called
with a single argument, the file at the
specified path will be used as input. If
called with the -m option, the following
argument will be parsed as a Markdown string.
"""
