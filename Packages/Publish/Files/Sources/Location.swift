//
//  Location.swift
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

/// Protocol adopted by types that represent locations on a file system.
public protocol Location: Equatable, CustomStringConvertible, Sendable {
  /// The kind of location that is being represented (see `LocationKind`).
  static var kind: LocationKind { get }
  /// The underlying storage for the item at the represented location.
  /// You don't interact with this object as part of the public API.
  var storage: Storage<Self> { get }
  /// Initialize an instance of this location with its underlying storage.
  /// You don't call this initializer as part of the public API, instead
  /// use `init(path:)` on either `File` or `Folder`.
  init(storage: Storage<Self>)
}

extension Location {
  /// A textual representation of the location, including its name and path.
  public var description: String {
    let typeName = String(describing: type(of: self))
    return "\(typeName)(name: \(name), path: \(path))"
  }

  /// The path of this location, relative to the root of the file system.
  public var path: String {
    storage.path
  }

  /// A URL representation of the location's `path`.
  public var url: URL {
    URL(fileURLWithPath: path)
  }

  // swift-format-ignore: NeverForceUnwrap
  /// The name of the location, including any `extension`.
  public var name: String {
    // `pathComponents` always contains at least the root ("/"), so its
    // `last` element is never `nil` for a file URL.
    // swiftlint:disable:next force_unwrapping
    url.pathComponents.last!
  }

  /// The name of the location, excluding its `extension`.
  public var nameExcludingExtension: String {
    let components = name.split(separator: ".")
    guard components.count > 1 else {
      return name
    }
    return components.dropLast().joined()
  }

  /// The file extension of the item at the location.
  public var `extension`: String? {
    let components = name.split(separator: ".")
    guard components.count > 1, let last = components.last else {
      return nil
    }
    return String(last)
  }

  /// The parent folder that this location is contained within.
  public var parent: Folder? {
    makeParentPath(for: path).flatMap {
      try? Folder(path: $0)
    }
  }

  /// The date when the item at this location was created.
  /// Only returns `nil` in case the item has now been deleted.
  public var creationDate: Date? {
    storage.attributes[.creationDate] as? Date
  }

  /// The date when the item at this location was last modified.
  /// Only returns `nil` in case the item has now been deleted.
  public var modificationDate: Date? {
    storage.attributes[.modificationDate] as? Date
  }

  /// Initialize an instance of an existing location at a given path.
  /// - parameter path: The absolute path of the location.
  /// - throws: `LocationError` if the item couldn't be found.
  public init(path: String) throws(LocationError) {
    try self.init(storage: Storage(path: path))
  }

  /// Compare two locations for equality based on their paths.
  /// - Parameters:
  ///   - lhs: The first location to compare.
  ///   - rhs: The second location to compare.
  /// - returns: `true` if both locations refer to the same path.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.storage.path == rhs.storage.path
  }

  /// Return the path of this location relative to a parent folder.
  /// For example, if this item is located at `/users/john/documents`
  /// and `/users/john` is passed, then `documents` is returned. If the
  /// passed folder isn't an ancestor of this item, then the item's
  /// absolute `path` is returned instead.
  /// - parameter folder: The folder to compare this item's path against.
  /// - returns: The path relative to the given folder.
  public func path(relativeTo folder: Folder) -> String {
    guard path.hasPrefix(folder.path) else {
      return path
    }

    let index = path.index(path.startIndex, offsetBy: folder.path.count)
    return String(path[index...]).removingSuffix("/")
  }

  /// Rename this location, keeping its existing `extension` by default.
  /// - Parameters:
  ///   - newName: The new name to give the location.
  ///   - keepExtension: Whether the location's `extension` should
  ///     remain unmodified (default: `true`).
  /// - throws: `LocationError` if the item couldn't be renamed.
  public func rename(to newName: String, keepExtension: Bool = true) throws(LocationError) {
    guard let parent = parent else {
      throw LocationError(path: path, reason: .cannotRenameRoot)
    }

    var newName = newName

    if keepExtension {
      `extension`.map {
        newName = newName.appendingSuffixIfNeeded(".\($0)")
      }
    }

    try storage.move(
      to: parent.path + newName,
      errorReasonProvider: LocationErrorReason.renameFailed
    )
  }

  /// Move this location to a new parent folder
  /// - parameter newParent: The folder to move this item to.
  /// - throws: `LocationError` if the location couldn't be moved.
  public func move(to newParent: Folder) throws(LocationError) {
    try storage.move(
      to: newParent.path + name,
      errorReasonProvider: LocationErrorReason.moveFailed
    )
  }

  /// Copy the contents of this location to a given folder
  /// - parameter folder: The folder to copy this item to.
  /// - throws: `LocationError` if the location couldn't be copied.
  /// - returns: The new, copied location.
  @discardableResult
  public func copy(to folder: Folder) throws(LocationError) -> Self {
    let path = folder.path + name
    try storage.copy(to: path)
    return try Self(path: path)
  }

  /// Delete this location. It will be permanently deleted. Use with caution.
  /// - throws: `LocationError` if the item couldn't be deleted.
  public func delete() throws(LocationError) {
    try storage.delete()
  }
}
