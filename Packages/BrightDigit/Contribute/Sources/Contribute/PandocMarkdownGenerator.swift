//
//  PandocMarkdownGenerator.swift
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

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Generates markdown from HTML string using [Pandoc](https://pandoc.org/).
public struct PandocMarkdownGenerator: MarkdownGenerator {
  /// A namespace for temporary file operations.
  public enum Temporary {
    /// The URL of the temporary directory.
    private static let temporaryDirURL: URL = .temporaryDir

    /// Creates a temporary file from the given content.
    ///
    /// - Parameter content: The content of the temporary file.
    /// - Returns: The URL of the created temporary file.
    /// - Throws: An error if the temporary file creation fails.
    public static func file(fromContent content: String) throws -> URL {
      let temporaryFileURL = temporaryDirURL.appendingPathComponent(UUID().uuidString)
      try content.write(to: temporaryFileURL, atomically: true, encoding: .utf8)
      return temporaryFileURL
    }
  }

  /// The function used for executing shell commands.
  private let shellOut: @Sendable (String, [String]) throws -> String

  /// The function used for creating temporary files.
  private let temporaryFile: @Sendable (String) throws -> URL

  /// The path to the Pandoc executable.
  private let pandocPath =
    ProcessInfo.processInfo.environment["PANDOC_PATH"]
    ?? "$(which pandoc)"

  /// Initializes a new `PandocMarkdownGenerator` instance.
  ///
  /// - Parameters:
  ///   - shellOut: A closure that executes a shell command and returns the output.
  ///   - temporaryFile: A closure that creates a temporary file from the given content.
  public init(
    shellOut: @escaping @Sendable (String, [String]) throws -> String,
    temporaryFile: @escaping @Sendable (String) throws -> URL = {
      try Temporary.file(fromContent: $0)
    }
  ) {
    self.shellOut = shellOut
    self.temporaryFile = temporaryFile
  }

  /// Converts the given HTML string to markdown by invoking Pandoc.
  ///
  /// - Parameter htmlString: The HTML string to convert.
  /// - Returns: The markdown produced by Pandoc.
  /// - Throws: An error if the temporary file cannot be created or the
  ///   Pandoc command fails.
  public func markdown(fromHTML htmlString: String) throws -> String {
    let temporaryFileURL = try temporaryFile(htmlString)
    return try shellOut(pandocPath, ["-f html -t markdown_strict", temporaryFileURL.path])
  }
}
