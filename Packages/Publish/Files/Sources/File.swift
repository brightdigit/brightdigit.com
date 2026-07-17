//
//  File.swift
//
//  Copyright (c) 2017-2019 John Sundell.
//  Licensed under the MIT license, as follows:
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// Type that represents a file on disk. You can either reference an existing
/// file by initializing an instance with a `path`, or you can create new files
/// using the various `createFile...` APIs available on `Folder`.
public struct File: Location {
  /// The underlying storage for the item at the represented location.
  public let storage: Storage<File>

  /// Initialize an instance of this file with its underlying storage.
  /// - parameter storage: The storage backing this file.
  public init(storage: Storage<File>) {
    self.storage = storage
  }
}

extension File {
  /// The kind of location that is being represented.
  public static var kind: LocationKind {
    .file
  }

  /// Write a new set of binary data into the file, replacing its current contents.
  /// - parameter data: The binary data to write.
  /// - throws: `WriteError` in case the operation couldn't be completed.
  public func write(_ data: Data) throws(WriteError) {
    do {
      try data.write(to: url)
    } catch {
      throw WriteError(path: path, reason: .writeFailed(error))
    }
  }

  /// Write a new string into the file, replacing its current contents.
  /// - Parameters:
  ///   - string: The string to write.
  ///   - encoding: The encoding of the string (default: `UTF8`).
  /// - throws: `WriteError` in case the operation couldn't be completed.
  public func write(_ string: String, encoding: String.Encoding = .utf8) throws(WriteError) {
    guard let data = string.data(using: encoding) else {
      throw WriteError(path: path, reason: .stringEncodingFailed(string))
    }

    return try write(data)
  }

  /// Append a set of binary data to the file's existing contents.
  /// - parameter data: The binary data to append.
  /// - throws: `WriteError` in case the operation couldn't be completed.
  public func append(_ data: Data) throws(WriteError) {
    do {
      let handle = try FileHandle(forWritingTo: url)
      handle.seekToEndOfFile()
      handle.write(data)
      handle.closeFile()
    } catch {
      throw WriteError(path: path, reason: .writeFailed(error))
    }
  }

  /// Append a string to the file's existing contents.
  /// - Parameters:
  ///   - string: The string to append.
  ///   - encoding: The encoding of the string (default: `UTF8`).
  /// - throws: `WriteError` in case the operation couldn't be completed.
  public func append(_ string: String, encoding: String.Encoding = .utf8) throws(WriteError) {
    guard let data = string.data(using: encoding) else {
      throw WriteError(path: path, reason: .stringEncodingFailed(string))
    }

    return try append(data)
  }

  /// Read the contents of the file as binary data.
  /// - throws: `ReadError` if the file couldn't be read.
  public func read() throws(ReadError) -> Data {
    do { return try Data(contentsOf: url) } catch {
      throw ReadError(path: path, reason: .readFailed(error))
    }
  }

  /// Read the contents of the file as a string.
  /// - parameter encoding: The encoding to decode the file's data using (default: `UTF8`).
  /// - throws: `ReadError` if the file couldn't be read, or if a string couldn't
  ///   be decoded from the file's contents.
  /// - returns: The decoded string contents of the file.
  public func readAsString(encodedAs encoding: String.Encoding = .utf8) throws(ReadError) -> String
  {
    guard let string = try String(data: read(), encoding: encoding) else {
      throw ReadError(path: path, reason: .stringDecodingFailed)
    }

    return string
  }

  /// Read the contents of the file as an integer.
  /// - throws: `ReadError` if the file couldn't be read, or if the file's
  ///   contents couldn't be converted into an integer.
  /// - returns: The integer parsed from the file's contents.
  public func readAsInt() throws(ReadError) -> Int {
    let string = try readAsString()

    guard let int = Int(string) else {
      throw ReadError(path: path, reason: .notAnInt(string))
    }

    return int
  }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

  import AppKit

  extension File {
    /// Open the file.
    public func open() {
      NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
  }

#endif
