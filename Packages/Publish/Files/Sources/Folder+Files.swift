//
//  Folder+Files.swift
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

extension Folder {
  /// Return a file at a given path within this folder.
  /// - parameter path: A relative path within this folder.
  /// - throws: `LocationError` if the file couldn't be found.
  /// - returns: The file located at the given path.
  public func file(at path: String) throws(LocationError) -> File {
    try storage.file(at: path)
  }

  /// Return a file within this folder with a given name.
  /// - parameter name: The name of the file to return.
  /// - throws: `LocationError` if the file couldn't be found.
  /// - returns: The file with the given name.
  public func file(named name: String) throws(LocationError) -> File {
    try storage.file(at: name)
  }

  /// Return whether this folder contains a file at a given path.
  /// - parameter path: The relative path of the file to look for.
  /// - returns: `true` if a file exists at the given path.
  public func containsFile(at path: String) -> Bool {
    (try? file(at: path)) != nil
  }

  /// Return whether this folder contains a file with a given name.
  /// - parameter name: The name of the file to look for.
  /// - returns: `true` if a file with the given name exists.
  public func containsFile(named name: String) -> Bool {
    (try? file(named: name)) != nil
  }

  /// Create a new file at a given path within this folder. In case
  /// the intermediate folders between this folder and the new file don't
  /// exist, those will be created as well. This method throws an error
  /// if a file already exists at the given path.
  /// - Parameters:
  ///   - path: The relative path of the file to create.
  ///   - contents: The initial `Data` that the file should contain.
  /// - throws: `WriteError` if the operation couldn't be completed.
  /// - returns: The newly created file.
  @discardableResult
  public func createFile(at path: String, contents: Data? = nil) throws(WriteError) -> File {
    try storage.createFile(at: path, contents: contents)
  }

  /// Create a new file with a given name. This method throws an error
  /// if a file with the given name already exists.
  /// - Parameters:
  ///   - fileName: The name of the file to create.
  ///   - contents: The initial `Data` that the file should contain.
  /// - throws: `WriteError` if the operation couldn't be completed.
  /// - returns: The newly created file.
  @discardableResult
  public func createFile(named fileName: String, contents: Data? = nil) throws(WriteError) -> File {
    try storage.createFile(at: fileName, contents: contents)
  }

  /// Create a new file at a given path within this folder. In case
  /// the intermediate folders between this folder and the new file don't
  /// exist, those will be created as well. If a file already exists at
  /// the given path, then it will be returned without modification.
  /// - Parameters:
  ///   - path: The relative path of the file.
  ///   - contents: The initial `Data` that any newly created file
  ///     should contain. Will only be evaluated if needed.
  /// - throws: `WriteError` if a new file couldn't be created.
  /// - returns: The existing or newly created file.
  @discardableResult
  public func createFileIfNeeded(
    at path: String,
    contents: @autoclosure () -> Data? = nil
  ) throws(WriteError) -> File {
    if let existing = try? file(at: path) {
      return existing
    }
    return try createFile(at: path, contents: contents())
  }

  /// Create a new file with a given name. If a file with the given
  /// name already exists, then it will be returned without modification.
  /// - Parameters:
  ///   - name: The name of the file.
  ///   - contents: The initial `Data` that any newly created file
  ///     should contain. Will only be evaluated if needed.
  /// - throws: `WriteError` if a new file couldn't be created.
  /// - returns: The existing or newly created file.
  @discardableResult
  public func createFileIfNeeded(
    withName name: String,
    contents: @autoclosure () -> Data? = nil
  ) throws(WriteError) -> File {
    if let existing = try? file(named: name) {
      return existing
    }
    return try createFile(named: name, contents: contents())
  }
}
