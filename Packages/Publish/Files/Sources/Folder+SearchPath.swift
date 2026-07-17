//
//  Folder+SearchPath.swift
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

#if os(iOS) || os(tvOS) || os(macOS)
  extension Folder {
    /// The current user's Documents folder
    public static var documents: Folder? {
      try? .matching(.documentDirectory)
    }

    /// The current user's Library folder
    public static var library: Folder? {
      try? .matching(.libraryDirectory)
    }

    /// Resolve a folder that matches a search path within a given domain.
    /// - Parameters:
    ///   - searchPath: The directory path to search for.
    ///   - domain: The domain to search in.
    ///   - fileManager: Which file manager to search using.
    /// - throws: `LocationError` if no folder could be resolved.
    /// - returns: The resolved folder for the given search path.
    public static func matching(
      _ searchPath: FileManager.SearchPathDirectory,
      in domain: FileManager.SearchPathDomainMask = .userDomainMask,
      resolvedBy fileManager: FileManager = .default
    ) throws -> Folder {
      let urls = fileManager.urls(for: searchPath, in: domain)

      guard let match = urls.first else {
        throw LocationError(
          path: "",
          reason: .unresolvedSearchPath(searchPath, domain: domain)
        )
      }

      return try Folder(storage: Storage(path: match.relativePath))
    }
  }
#endif
