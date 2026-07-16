//
//  FilesTests+Folders.swift
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

extension FilesTests {
  internal func testCreatingSubfolderAtPath() {
    performTest {
      let path = "a/b/c"

      XCTAssertFalse(folder.containsSubfolder(at: path))
      try folder.createSubfolder(at: path).createFile(named: "d.txt")

      XCTAssertTrue(folder.containsSubfolder(at: path))
      XCTAssertTrue(folder.containsSubfolder(named: "a"))
      XCTAssertTrue(folder.containsSubfolder(at: "a/b"))
      XCTAssertTrue(folder.containsFile(at: "a/b/c/d.txt"))

      let subfolder = try folder.createSubfolderIfNeeded(at: path)
      XCTAssertEqual(subfolder.files.names(), ["d.txt"])
    }
  }

  internal func testDroppingLeadingSlashWhenCreatingSubfolderAtPath() {
    performTest {
      let path = "a/b/c"

      XCTAssertFalse(folder.containsSubfolder(at: path))
      try folder.createSubfolder(at: path).createFile(named: "d.txt")

      XCTAssertTrue(folder.containsSubfolder(at: path))
      XCTAssertTrue(folder.containsSubfolder(named: "a"))
      XCTAssertTrue(folder.containsSubfolder(at: "/a/b"))
      XCTAssertTrue(folder.containsFile(at: "/a/b/c/d.txt"))

      let subfolder = try folder.createSubfolderIfNeeded(at: path)
      XCTAssertEqual(subfolder.files.names(), ["d.txt"])
    }
  }

  internal func testCreateFolderIfNeeded() {
    performTest {
      let subfolderA = try folder.createSubfolderIfNeeded(withName: "Subfolder")
      try subfolderA.createFile(named: "file")
      let subfolderB = try folder.createSubfolderIfNeeded(withName: subfolderA.name)
      XCTAssertEqual(subfolderA, subfolderB)
      XCTAssertEqual(subfolderA.files.count(), subfolderB.files.count())
      XCTAssertEqual(subfolderA.files.first, subfolderB.files.first)
    }
  }

  internal func testCreateSubfolderIfNeeded() {
    performTest {
      let subfolderA = try folder.createSubfolderIfNeeded(withName: "folder")
      try subfolderA.createFile(named: "file")
      let subfolderB = try folder.createSubfolderIfNeeded(withName: "folder")
      XCTAssertEqual(subfolderA, subfolderB)
      XCTAssertEqual(subfolderA.files.count(), subfolderB.files.count())
      XCTAssertEqual(subfolderA.files.first, subfolderB.files.first)
    }
  }

  internal func testFolderContainsFile() {
    performTest {
      let subfolder = try folder.createSubfolder(named: "subfolder")
      let fileA = try subfolder.createFile(named: "A")
      XCTAssertFalse(folder.contains(fileA))

      let fileB = try folder.createFile(named: "B")
      XCTAssertTrue(folder.contains(fileB))
    }
  }

  internal func testFolderContainsSubfolder() {
    performTest {
      let subfolder = try folder.createSubfolder(named: "subfolder")
      let subfolderA = try subfolder.createSubfolder(named: "A")
      XCTAssertFalse(folder.contains(subfolderA))

      let subfolderB = try folder.createSubfolder(named: "B")
      XCTAssertTrue(folder.contains(subfolderB))
    }
  }
}
