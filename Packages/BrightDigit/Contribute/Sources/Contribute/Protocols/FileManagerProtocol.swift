//
//  FileManagerProtocol.swift
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

/// A protocol that defines file management methods.
public protocol FileManagerProtocol {
  /// Creates a directory at the specified URL.
  ///
  /// - Parameters:
  ///   - url: The URL of the directory to be created.
  ///   - createIntermediates: A boolean value indicating whether any nonexistent parent
  ///   directories should be created if they don't exist..
  ///   - attributes: An optional dictionary of file attributes to be applied.
  /// - Throws: An error if the directory creation fails.
  func createDirectory(
    at url: URL,
    withIntermediateDirectories createIntermediates: Bool,
    attributes: [FileAttributeKey: Any]?
  ) throws

  /// Checks whether a file exists at the specified path.
  ///
  /// - Parameter path: The file path to be checked.
  /// - Returns: `true` if the file exists, `false` otherwise.
  func fileExists(atPath path: String) -> Bool

  /// Copies a file or directory from the source URL to the destination URL.
  ///
  /// - Parameters:
  ///   - srcURL: The source URL of the item to be copied.
  ///   - dstURL: The destination URL where the item should be copied to.
  /// - Throws: An error if the copy operation fails.
  func copyItem(at srcURL: URL, to dstURL: URL) throws

  /// Removes a file or directory at the specified URL.
  ///
  /// - Parameter url: The URL of the item to be removed.
  /// - Throws: An error if the removal fails.
  func removeItem(at url: URL) throws
}

extension FileManagerProtocol {
  /// Creates a directory at the specified URL.
  /// By default, It will create any nonexistent parent directories if they don't exist..
  ///
  /// - Parameters:
  ///   - url: The URL of the directory to be created.
  ///   - createIntermediates: A boolean value indicating whether any nonexistent parent
  ///   directories should be created if they don't exist. Default value is `true`.
  /// - Throws: An error if the directory creation fails.
  public func createDirectory(
    at url: URL,
    withIntermediateDirectories createIntermediates: Bool = true
  ) throws {
    try createDirectory(
      at: url,
      withIntermediateDirectories: createIntermediates,
      attributes: nil
    )
  }
}

extension FileManager: FileManagerProtocol {}
