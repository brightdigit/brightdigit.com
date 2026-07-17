//
//  FilesTests+SearchPath.swift
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

import Files
import Foundation
import XCTest

#if os(macOS)
  extension FilesTests {
    internal func testAccessingDocumentsFolder() {
      XCTAssertNotNil(Folder.documents, "Documents folder should be available.")
    }
  }
#endif

#if os(iOS) || os(tvOS) || os(macOS)
  extension FilesTests {
    internal func testAccessingLibraryFolder() {
      XCTAssertNotNil(Folder.library, "Library folder should be available.")
    }

    internal func testResolvingFolderMatchingSearchPath() {
      performTest {
        // Real file I/O
        XCTAssertNotNil(try Folder.matching(.cachesDirectory))
        XCTAssertNotNil(try Folder.matching(.libraryDirectory))

        // Mocked file I/O
        final class FileManagerMock: FileManager {
          var target: Folder?

          override func urls(
            for directory: FileManager.SearchPathDirectory,
            in domainMask: FileManager.SearchPathDomainMask
          ) -> [URL] {
            target.map { [$0.url] } ?? []
          }
        }

        let target = try folder.createSubfolder(named: "Target")

        let fileManager = FileManagerMock()
        fileManager.target = target

        let resolved = try Folder.matching(
          .documentDirectory,
          resolvedBy: fileManager
        )

        XCTAssertEqual(resolved, target)
      }
    }
  }
#endif
