//
//  Folder+Children.swift
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
  /// A sequence of child locations contained within a given folder.
  /// You obtain an instance of this type by accessing either `files`
  /// or `subfolders` on a `Folder` instance.
  public struct ChildSequence<Child: Location>: Sequence {
    internal let folder: Folder
    internal let fileManager: FileManager
    internal var isRecursive: Bool
    internal var includeHidden: Bool

    /// Create an iterator that traverses this sequence's child locations.
    /// - returns: A new iterator over the sequence's contents.
    public func makeIterator() -> ChildIterator<Child> {
      ChildIterator(
        folder: folder,
        fileManager: fileManager,
        isRecursive: isRecursive,
        includeHidden: includeHidden,
        reverseTopLevelTraversal: false
      )
    }
  }

  /// The type of iterator used by `ChildSequence`. You don't interact
  /// with this type directly. See `ChildSequence` for more information.
  public struct ChildIterator<Child: Location>: IteratorProtocol {
    private let folder: Folder
    private let fileManager: FileManager
    private let isRecursive: Bool
    private let includeHidden: Bool
    private let reverseTopLevelTraversal: Bool
    private lazy var itemNames = loadItemNames()
    private var index = 0
    private var nestedIterators = [ChildIterator<Child>]()

    internal init(
      folder: Folder,
      fileManager: FileManager,
      isRecursive: Bool,
      includeHidden: Bool,
      reverseTopLevelTraversal: Bool
    ) {
      self.folder = folder
      self.fileManager = fileManager
      self.isRecursive = isRecursive
      self.includeHidden = includeHidden
      self.reverseTopLevelTraversal = reverseTopLevelTraversal
    }

    // swiftlint:disable cyclomatic_complexity
    /// Advance to and return the next child location, or `nil` when the
    /// sequence has been exhausted.
    /// - returns: The next child location, or `nil` if there are no more.
    public mutating func next() -> Child? {
      guard index < itemNames.count else {
        guard var nested = nestedIterators.first else {
          return nil
        }

        guard let child = nested.next() else {
          nestedIterators.removeFirst()
          return next()
        }

        nestedIterators[0] = nested
        return child
      }

      let name = itemNames[index]
      index += 1

      if !includeHidden {
        guard !name.hasPrefix(".") else {
          return next()
        }
      }

      let childPath = folder.path + name.removingPrefix("/")
      let childStorage = try? Storage<Child>(path: childPath)
      let child = childStorage.map(Child.init)

      if isRecursive {
        let childFolder =
          (child as? Folder)
          ?? (try? Folder(
            storage: Storage(path: childPath)
          ))

        if let childFolder = childFolder {
          let nested = ChildIterator(
            folder: childFolder,
            fileManager: fileManager,
            isRecursive: true,
            includeHidden: includeHidden,
            reverseTopLevelTraversal: false
          )

          nestedIterators.append(nested)
        }
      }

      return child ?? next()
    }
    // swiftlint:enable cyclomatic_complexity

    private mutating func loadItemNames() -> [String] {
      let contents = try? fileManager.contentsOfDirectory(atPath: folder.path)
      let names = contents?.sorted() ?? []
      return reverseTopLevelTraversal ? names.reversed() : names
    }
  }
}

extension Folder.ChildSequence: CustomStringConvertible {
  /// A textual representation of the sequence, listing each child's
  /// description on its own line.
  public var description: String {
    lazy.map({ $0.description }).joined(separator: "\n")
  }
}
