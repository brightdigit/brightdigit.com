//
//  Storage+Folder.swift
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

extension Storage where LocationType == Folder {
  internal func makeChildSequence<T: Location>() -> Folder.ChildSequence<T> {
    Folder.ChildSequence(
      folder: Folder(storage: self),
      fileManager: .default,
      isRecursive: false,
      includeHidden: false
    )
  }

  internal func subfolder(at folderPath: String) throws(LocationError) -> Folder {
    let folderPath = path + folderPath.removingPrefix("/")
    let storage = try Storage(path: folderPath)
    return Folder(storage: storage)
  }

  internal func file(at filePath: String) throws(LocationError) -> File {
    let filePath = path + filePath.removingPrefix("/")
    let storage = try Storage<File>(path: filePath)
    return File(storage: storage)
  }

  internal func createSubfolder(at folderPath: String) throws(WriteError) -> Folder {
    let folderPath = path + folderPath.removingPrefix("/")

    guard folderPath != path else {
      throw WriteError(path: folderPath, reason: .emptyPath)
    }

    do {
      try FileManager.default.createDirectory(
        atPath: folderPath,
        withIntermediateDirectories: true
      )

      let storage = try Storage(path: folderPath)
      return Folder(storage: storage)
    } catch {
      throw WriteError(path: folderPath, reason: .folderCreationFailed(error))
    }
  }

  internal func createFile(at filePath: String, contents: Data?) throws(WriteError) -> File {
    let filePath = path + filePath.removingPrefix("/")

    guard let parentPath = makeParentPath(for: filePath) else {
      throw WriteError(path: filePath, reason: .emptyPath)
    }

    if parentPath != path {
      do {
        try FileManager.default.createDirectory(
          atPath: parentPath,
          withIntermediateDirectories: true
        )
      } catch {
        throw WriteError(path: parentPath, reason: .folderCreationFailed(error))
      }
    }

    guard FileManager.default.createFile(atPath: filePath, contents: contents),
      let storage = try? Storage<File>(path: filePath)
    else {
      throw WriteError(path: filePath, reason: .fileCreationFailed)
    }

    return File(storage: storage)
  }
}
