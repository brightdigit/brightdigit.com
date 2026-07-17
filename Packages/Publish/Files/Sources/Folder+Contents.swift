//
//  Folder+Contents.swift
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

extension Folder {
  /// Return whether this folder contains a given location as a direct child.
  /// - parameter location: The location to find.
  /// - returns: `true` if the location is a direct child of this folder.
  public func contains<T: Location>(_ location: T) -> Bool {
    switch T.kind {
    case .file: return containsFile(named: location.name)
    case .folder: return containsSubfolder(named: location.name)
    }
  }

  /// Move the contents of this folder to a new parent
  /// - Parameters:
  ///   - folder: The new parent folder to move this folder's contents to.
  ///   - includeHidden: Whether hidden files should be included (default: `false`).
  /// - throws: `LocationError` if the operation couldn't be completed.
  public func moveContents(to folder: Folder, includeHidden: Bool = false) throws(LocationError) {
    var files = self.files
    files.includeHidden = includeHidden
    try files.move(to: folder)

    var folders = subfolders
    folders.includeHidden = includeHidden
    try folders.move(to: folder)
  }

  /// Empty this folder, permanently deleting all of its contents. Use with caution.
  /// - parameter includeHidden: Whether hidden files should also be deleted (default: `false`).
  /// - throws: `LocationError` if the operation couldn't be completed.
  public func empty(includingHidden includeHidden: Bool = false) throws(LocationError) {
    var files = self.files
    files.includeHidden = includeHidden
    try files.delete()

    var folders = subfolders
    folders.includeHidden = includeHidden
    try folders.delete()
  }

  /// Return whether this folder doesn't contain any locations.
  /// - parameter includeHidden: Whether hidden files should be considered (default: `false`).
  /// - returns: `true` if the folder contains no matching locations.
  public func isEmpty(includingHidden includeHidden: Bool = false) -> Bool {
    var files = self.files
    files.includeHidden = includeHidden

    if files.first != nil {
      return false
    }

    var folders = subfolders
    folders.includeHidden = includeHidden
    return folders.first == nil
  }
}
