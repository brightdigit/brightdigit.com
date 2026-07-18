//
//  PathTests.swift
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

import XCTest

@testable import Files

// Filesystem-free coverage for the internal path helpers, so the separator and
// parent-derivation string math is exercised on every platform (including the
// Windows-only branches, via synthetic `C:/…` inputs) without needing a Windows
// runner.
internal final class PathTests: XCTestCase {
  internal func testCanonicalNativeRoundTripIsIdempotent() {
    let paths = [
      "/Users/example/.filesTest/",
      "C:/Users/example/.filesTest/",
      "relative/child/leaf",
      "/",
    ]

    for path in paths {
      XCTAssertEqual(path.canonicalizedPath.canonicalizedPath, path.canonicalizedPath)
      XCTAssertEqual(path.nativePath.nativePath, path.nativePath)
      // Converting to native and back to canonical is a no-op on canonical input.
      XCTAssertEqual(path.canonicalizedPath.nativePath.canonicalizedPath, path.canonicalizedPath)
    }
  }

  internal func testCanonicalizedPathHandlesSeparatorsPerPlatform() {
    // `canonicalizedPath` rewrites native separators only on Windows; elsewhere
    // it is the identity (so macOS/Linux behavior is provably unchanged).
    #if os(Windows)
      XCTAssertFalse("C:\\Users\\example".canonicalizedPath.contains("\\"))
      XCTAssertEqual("C:\\Users\\example".canonicalizedPath, "C:/Users/example")
    #else
      XCTAssertEqual("C:\\Users\\example".canonicalizedPath, "C:\\Users\\example")
    #endif
    XCTAssertEqual("plain/forward/slash".canonicalizedPath, "plain/forward/slash")
  }

  internal func testMakeParentPathForPOSIXPaths() {
    // `URL(fileURLWithPath:)` strips a trailing slash, so the parent of a
    // folder `…/example/folder/` is `…/example/` (the folder's containing dir).
    XCTAssertEqual(makeParentPath(for: "/Users/example/file"), "/Users/example/")
    XCTAssertEqual(makeParentPath(for: "/Users/example/folder/"), "/Users/example/")
    XCTAssertEqual(makeParentPath(for: "/Users/file"), "/Users/")
    XCTAssertEqual(makeParentPath(for: "/file"), "/")
    XCTAssertNil(makeParentPath(for: "/"))
  }

  internal func testMakeParentPathPreservesWindowsDrivePrefix() {
    // These synthetic canonical Windows paths exercise the drive-prefix split and
    // rejoin on every platform, so the logic is validated off Windows too. The
    // rejoined result keeps the `C:` prefix rather than collapsing to a POSIX `/…`.
    XCTAssertEqual(makeParentPath(for: "C:/Users/example/folder/"), "C:/Users/example/")
    XCTAssertEqual(makeParentPath(for: "C:/Users/file"), "C:/Users/")
    XCTAssertEqual(makeParentPath(for: "C:/file"), "C:/")
  }

  internal func testMakeParentPathAtDriveRootIsNilOnWindows() {
    // The drive-root guard is Windows-only (a drive root has no parent); off
    // Windows `C:/` is just an ordinary relative-looking path.
    #if os(Windows)
      XCTAssertNil(makeParentPath(for: "C:/"))
      XCTAssertNil(makeParentPath(for: "C:"))
    #endif
  }

  internal func testIsDriveRoot() {
    #if os(Windows)
      XCTAssertTrue("C:/".isDriveRoot)
      XCTAssertTrue("C:".isDriveRoot)
      XCTAssertFalse("C:/Users".isDriveRoot)
    #else
      XCTAssertFalse("C:/".isDriveRoot)
      XCTAssertFalse("/".isDriveRoot)
    #endif
  }
}
