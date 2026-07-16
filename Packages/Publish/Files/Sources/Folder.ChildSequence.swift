//
//  Folder.ChildSequence.swift
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

extension Folder.ChildSequence {
  /// Return a new instance of this sequence that'll traverse the folder's
  /// contents recursively, in a breadth-first manner. Complexity: `O(1)`.
  public var recursive: Folder.ChildSequence<Child> {
    var sequence = self
    sequence.isRecursive = true
    return sequence
  }

  /// Return a new instance of this sequence that'll include all hidden
  /// (dot) files when traversing the folder's contents. Complexity: `O(1)`.
  public var includingHidden: Folder.ChildSequence<Child> {
    var sequence = self
    sequence.includeHidden = true
    return sequence
  }

  /// Return the first location contained within this sequence.
  /// Complexity: `O(1)`.
  public var first: Child? {
    var iterator = makeIterator()
    return iterator.next()
  }

  /// Count the number of locations contained within this sequence.
  /// Complexity: `O(N)`.
  /// - returns: The number of locations in the sequence.
  public func count() -> Int {
    reduce(0) { count, _ in count + 1 }
  }

  /// Gather the names of all of the locations contained within this sequence.
  /// Complexity: `O(N)`.
  /// - returns: The names of the locations in the sequence.
  public func names() -> [String] {
    map { $0.name }
  }

  /// Return the last location contained within this sequence.
  /// Complexity: `O(N)`.
  /// - returns: The last location, or `nil` if the sequence is empty.
  public func last() -> Child? {
    var iterator = Iterator(
      folder: folder,
      fileManager: fileManager,
      isRecursive: isRecursive,
      includeHidden: includeHidden,
      reverseTopLevelTraversal: !isRecursive
    )

    guard isRecursive else {
      return iterator.next()
    }

    var child: Child?

    while let nextChild = iterator.next() {
      child = nextChild
    }

    return child
  }

  /// Move all locations within this sequence to a new parent folder.
  /// - parameter folder: The folder to move all locations to.
  /// - throws: `LocationError` if the move couldn't be completed.
  public func move(to folder: Folder) throws(LocationError) {
    for child in self { try child.move(to: folder) }
  }

  /// Delete all of the locations within this sequence. All items will
  /// be permanently deleted. Use with caution.
  /// - throws: `LocationError` if an item couldn't be deleted. Note that
  ///   all items deleted up to that point won't be recovered.
  public func delete() throws(LocationError) {
    for child in self { try child.delete() }
  }
}
