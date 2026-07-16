//
//  LocationErrorReason.swift
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

/// Enum listing reasons that a location manipulation could fail.
public enum LocationErrorReason: Sendable {
  /// The location couldn't be found.
  case missing
  /// An empty path was given when refering to a file.
  case emptyFilePath
  /// The user attempted to rename the file system's root folder.
  case cannotRenameRoot
  /// A rename operation failed with an underlying system error.
  case renameFailed(any Error & Sendable)
  /// A move operation failed with an underlying system error.
  case moveFailed(any Error & Sendable)
  /// A copy operation failed with an underlying system error.
  case copyFailed(any Error & Sendable)
  /// A delete operation failed with an underlying system error.
  case deleteFailed(any Error & Sendable)
  /// A search path couldn't be resolved within a given domain.
  case unresolvedSearchPath(
    FileManager.SearchPathDirectory,
    domain: FileManager.SearchPathDomainMask
  )
}
