//
//  FilesTests+MovingCopying.swift
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
  internal func testMovingFiles() {
    performTest {
      try folder.createFile(named: "A")
      try folder.createFile(named: "B")
      XCTAssertEqual(folder.files.count(), 2)

      let subfolder = try folder.createSubfolder(named: "folder")
      try folder.files.move(to: subfolder)
      try XCTAssertNotNil(subfolder.file(named: "A"))
      try XCTAssertNotNil(subfolder.file(named: "B"))
      XCTAssertEqual(folder.files.count(), 0)
    }
  }

  internal func testCopyingFiles() {
    performTest {
      let file = try folder.createFile(named: "A")
      try file.write("content")

      let subfolder = try folder.createSubfolder(named: "folder")
      let copiedFile = try file.copy(to: subfolder)
      try XCTAssertNotNil(folder.file(named: "A"))
      try XCTAssertNotNil(subfolder.file(named: "A"))
      try XCTAssertEqual(file.read(), subfolder.file(named: "A").read())
      try XCTAssertEqual(copiedFile, subfolder.file(named: "A"))
      XCTAssertEqual(folder.files.count(), 1)
    }
  }

  internal func testMovingFolders() {
    performTest {
      let folderA = try folder.createSubfolder(named: "A")
      let folderB = try folderA.createSubfolder(named: "B")
      _ = try folderB.createSubfolder(named: "C")

      try folderB.move(to: folder)
      XCTAssertTrue(folder.containsSubfolder(named: "B"))
      XCTAssertTrue(folderB.containsSubfolder(named: "C"))
    }
  }

  internal func testCopyingFolders() {
    performTest {
      let copyingFolder = try folder.createSubfolder(named: "A")

      let subfolder = try folder.createSubfolder(named: "folder")
      let copiedFolder = try copyingFolder.copy(to: subfolder)
      XCTAssertTrue(folder.containsSubfolder(named: "A"))
      XCTAssertTrue(subfolder.containsSubfolder(named: "A"))
      XCTAssertEqual(copiedFolder, try subfolder.subfolder(named: "A"))
      XCTAssertEqual(folder.subfolders.count(), 2)
      XCTAssertEqual(subfolder.subfolders.count(), 1)
    }
  }

  internal func testOpeningFileWithEmptyPathThrows() {
    performTest {
      try assert(File(path: ""), throwsErrorOfType: LocationError.self)
    }
  }

  internal func testDeletingNonExistingFileThrows() {
    performTest {
      let file = try folder.createFile(named: "file")
      try file.delete()
      try assert(file.delete(), throwsErrorOfType: LocationError.self)
    }
  }

  internal func testMovingFolderContents() {
    performTest {
      let parentFolder = try folder.createSubfolder(named: "parentA")
      try parentFolder.createSubfolder(named: "folderA")
      try parentFolder.createSubfolder(named: "folderB")
      try parentFolder.createFile(named: "fileA")
      try parentFolder.createFile(named: "fileB")

      XCTAssertEqual(parentFolder.subfolders.names(), ["folderA", "folderB"])
      XCTAssertEqual(parentFolder.files.names(), ["fileA", "fileB"])

      let newParentFolder = try folder.createSubfolder(named: "parentB")
      try parentFolder.moveContents(to: newParentFolder)

      XCTAssertEqual(parentFolder.subfolders.names(), [])
      XCTAssertEqual(parentFolder.files.names(), [])
      XCTAssertEqual(newParentFolder.subfolders.names(), ["folderA", "folderB"])
      XCTAssertEqual(newParentFolder.files.names(), ["fileA", "fileB"])
    }
  }

  internal func testMovingFolderHiddenContents() {
    performTest {
      let parentFolder = try folder.createSubfolder(named: "parent")
      try parentFolder.createFile(named: ".hidden")
      try parentFolder.createSubfolder(named: ".folder")

      XCTAssertEqual(parentFolder.files.includingHidden.names(), [".hidden"])
      XCTAssertEqual(parentFolder.subfolders.includingHidden.names(), [".folder"])

      let newParentFolder = try folder.createSubfolder(named: "parentB")
      try parentFolder.moveContents(to: newParentFolder, includeHidden: true)

      XCTAssertEqual(parentFolder.files.includingHidden.names(), [])
      XCTAssertEqual(parentFolder.subfolders.includingHidden.names(), [])
      XCTAssertEqual(newParentFolder.files.includingHidden.names(), [".hidden"])
      XCTAssertEqual(newParentFolder.subfolders.includingHidden.names(), [".folder"])
    }
  }
}
