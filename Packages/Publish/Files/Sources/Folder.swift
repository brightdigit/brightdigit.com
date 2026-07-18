//
//  Folder.swift
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

/// Type that represents a folder on disk. You can either reference an existing
/// folder by initializing an instance with a `path`, or you can create new
/// subfolders using this type's various `createSubfolder...` APIs.
public struct Folder: Location {
  /// The underlying storage for the item at the represented location.
  public let storage: Storage<Folder>

  /// Initialize an instance of this folder with its underlying storage.
  /// - parameter storage: The storage backing this folder.
  public init(storage: Storage<Folder>) {
    self.storage = storage
  }
}

extension Folder {
  /// The kind of location that is being represented.
  public static var kind: LocationKind {
    .folder
  }

  // swift-format-ignore: NeverUseForceTry
  /// The folder that the program is currently operating in.
  public static var current: Folder {
    // The current working directory always resolves to an existing folder.
    // swiftlint:disable:next force_try
    try! Folder(path: "")
  }

  // swift-format-ignore: NeverUseForceTry
  /// The root folder of the file system.
  ///
  /// On Windows this is the root of the current working volume (e.g. `C:/`),
  /// because Windows has no single filesystem root; elsewhere it is `/`.
  public static var root: Folder {
    // The file system root always exists.
    // swiftlint:disable:next force_try
    try! Folder(path: Path.rootPath)
  }

  // swift-format-ignore: NeverUseForceTry
  /// The current user's Home folder.
  public static var home: Folder {
    // A process always has a resolvable home folder.
    // swiftlint:disable:next force_try
    try! Folder(path: "~")
  }

  // swift-format-ignore: NeverUseForceTry
  /// The system's temporary folder.
  public static var temporary: Folder {
    // The system temporary folder always exists.
    // swiftlint:disable:next force_try
    try! Folder(path: NSTemporaryDirectory())
  }

  /// A sequence containing all of this folder's subfolders. Initially
  /// non-recursive, use `recursive` on the returned sequence to change that.
  public var subfolders: ChildSequence<Folder> {
    storage.makeChildSequence()
  }

  /// A sequence containing all of this folder's files. Initially
  /// non-recursive, use `recursive` on the returned sequence to change that.
  public var files: ChildSequence<File> {
    storage.makeChildSequence()
  }
}
