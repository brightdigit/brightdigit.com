//
//  Storage.swift
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
import Synchronization

/// Type used to store information about a given file system location. You don't
/// interact with this type as part of the public API, instead you use the APIs
/// exposed by `Location`, `File`, and `Folder`.
public final class Storage<LocationType: Location>: Sendable {
  // `path` is mutated in place by `move`/`rename`, so it is guarded by a
  // Mutex to keep `Storage` (and therefore `File`/`Folder`) `Sendable`
  // without an unchecked conformance. The file manager is always the shared
  // `.default` instance (which isn't `Sendable`), so it is accessed through a
  // computed property rather than stored.
  private let pathStorage: Mutex<String>

  internal var path: String { pathStorage.withLock { $0 } }

  internal init(path: String) throws(LocationError) {
    pathStorage = Mutex(try Storage.validatedPath(from: path))
  }

  // Paths are stored in canonical (forward-slash) form; the normalization logic
  // is inherently branchy.
  // swiftlint:disable:next cyclomatic_complexity
  private static func validatedPath(from inputPath: String) throws(LocationError) -> String {
    // Accept either separator on input and work in canonical (forward-slash) form.
    var path = inputPath.canonicalizedPath

    switch LocationType.kind {
    case .file:
      guard !path.isEmpty else {
        throw LocationError(path: path, reason: .emptyFilePath)
      }
    case .folder:
      if path.isEmpty { path = FileManager.default.currentDirectoryPath.canonicalizedPath }
      if !path.hasSuffix("/") { path += "/" }
    }

    if path.hasPrefix("~") {
      // `NSHomeDirectory()` is platform-aware (Windows resolves the user profile,
      // not the POSIX-only `HOME` variable) and, unlike
      // `FileManager.homeDirectoryForCurrentUser`, is available on every Apple
      // platform (iOS/tvOS/watchOS included).
      let homePath = NSHomeDirectory().canonicalizedPath
      path = homePath + path.dropFirst()
    }

    while let parentReferenceRange = path.range(of: "../") {
      let folderPath = String(path[..<parentReferenceRange.lowerBound])
      let parentPath = makeParentPath(for: folderPath) ?? "/"

      guard FileManager.default.locationExists(at: parentPath, kind: .folder) else {
        throw LocationError(path: parentPath, reason: .missing)
      }

      path.replaceSubrange(..<parentReferenceRange.upperBound, with: parentPath)
    }

    guard FileManager.default.locationExists(at: path, kind: LocationType.kind) else {
      throw LocationError(path: path, reason: .missing)
    }

    return path
  }
}

/// Compute the path of the parent folder for a given (canonical, forward-slash)
/// path, or `nil` when the path represents the root of the file system.
/// - parameter path: The path whose parent should be computed.
/// - returns: The parent folder's path in canonical form, or `nil` if `path` is
///   the root (`/` on POSIX, a volume root such as `C:/` on Windows).
internal func makeParentPath(for path: String) -> String? {
  guard path != "/", !path.isDriveRoot else {
    return nil
  }

  // On Windows, split off any drive prefix (e.g. "C:") so it can be restored
  // after `URL.pathComponents` (which drops it) rejoins the remainder. On other
  // platforms `drivePrefix` is empty and this is identical to the original logic.
  let drivePrefix: String
  let remainder: String
  if let colon = path.firstIndex(of: ":") {
    drivePrefix = String(path[...colon])
    remainder = String(path[path.index(after: colon)...])
  } else {
    drivePrefix = ""
    remainder = path
  }

  let url = URL(fileURLWithPath: remainder.nativePath)
  let components = url.pathComponents.dropFirst().dropLast()
  guard !components.isEmpty else {
    return drivePrefix.isEmpty ? "/" : drivePrefix + "/"
  }
  return drivePrefix + "/" + components.joined(separator: "/") + "/"
}

extension Storage {
  internal var attributes: [FileAttributeKey: Any] {
    (try? FileManager.default.attributesOfItem(atPath: path.nativePath)) ?? [:]
  }

  internal func move(
    to newPath: String,
    errorReasonProvider: (any Error & Sendable) -> LocationErrorReason
  ) throws(LocationError) {
    do {
      try FileManager.default.moveItem(atPath: path.nativePath, toPath: newPath.nativePath)

      // Store the new path in canonical (forward-slash) form.
      let canonical = newPath.canonicalizedPath
      switch LocationType.kind {
      case .file:
        pathStorage.withLock { $0 = canonical }
      case .folder:
        pathStorage.withLock { $0 = canonical.appendingSuffixIfNeeded("/") }
      }
    } catch {
      throw LocationError(path: path, reason: errorReasonProvider(error))
    }
  }

  internal func copy(to newPath: String) throws(LocationError) {
    do {
      try FileManager.default.copyItem(
        at: URL(fileURLWithPath: path.nativePath),
        to: URL(fileURLWithPath: newPath.nativePath)
      )
    } catch {
      throw LocationError(path: path, reason: .copyFailed(error))
    }
  }

  internal func delete() throws(LocationError) {
    do {
      try FileManager.default.removeItem(atPath: path.nativePath)
    } catch {
      throw LocationError(path: path, reason: .deleteFailed(error))
    }
  }
}
