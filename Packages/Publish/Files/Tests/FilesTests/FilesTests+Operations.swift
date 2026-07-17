//
//  FilesTests+Operations.swift
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
  internal func testCreatingAndDeletingFile() {
    performTest {
      // Verify that the file doesn't exist
      XCTAssertFalse(folder.containsFile(named: "test.txt"))

      // Create a file and verify its properties
      let file = try folder.createFile(named: "test.txt")
      XCTAssertEqual(file.name, "test.txt")
      XCTAssertEqual(file.path, folder.path + "test.txt")
      XCTAssertEqual(file.extension, "txt")
      XCTAssertEqual(file.nameExcludingExtension, "test")
      try XCTAssertEqual(file.read(), Data())

      // You should now be able to access the file using its path and through the parent
      _ = try File(path: file.path)
      XCTAssertTrue(folder.containsFile(named: "test.txt"))

      try file.delete()

      // Attempting to read the file should now throw an error
      try assert(file.read(), throwsErrorOfType: ReadError.self)

      // Attempting to create a File instance with the path should now also fail
      try assert(File(path: file.path), throwsErrorOfType: LocationError.self)
    }
  }

  internal func testCreatingAndDeletingFolder() {
    performTest {
      // Verify that the folder doesn't exist
      XCTAssertFalse(folder.containsSubfolder(named: "folder"))

      // Create a folder and verify its properties
      let subfolder = try folder.createSubfolder(named: "folder")
      XCTAssertEqual(subfolder.name, "folder")
      XCTAssertEqual(subfolder.path, folder.path + "folder/")

      // You should now be able to access the folder using its path and through the parent
      _ = try Folder(path: subfolder.path)
      XCTAssertTrue(folder.containsSubfolder(named: "folder"))

      // Put a file in the folder
      let file = try subfolder.createFile(named: "file")
      try XCTAssertEqual(file.read(), Data())

      try subfolder.delete()

      // Attempting to create a Folder instance with the path should now fail
      try assert(Folder(path: subfolder.path), throwsErrorOfType: LocationError.self)

      // The file contained in the folder should now also be deleted
      try assert(file.read(), throwsErrorOfType: ReadError.self)
    }
  }

  internal func testRenamingFile() {
    performTest {
      let file = try folder.createFile(named: "file.json")
      try file.rename(to: "renamedFile")
      XCTAssertEqual(file.name, "renamedFile.json")
      XCTAssertEqual(file.path, folder.path + "renamedFile.json")
      XCTAssertEqual(file.extension, "json")

      // Now try renaming the file, replacing its extension
      try file.rename(to: "other.txt", keepExtension: false)
      XCTAssertEqual(file.name, "other.txt")
      XCTAssertEqual(file.path, folder.path + "other.txt")
      XCTAssertEqual(file.extension, "txt")
    }
  }

  internal func testRenamingFileWithNameIncludingExtension() {
    performTest {
      let file = try folder.createFile(named: "file.json")
      try file.rename(to: "renamedFile.json")
      XCTAssertEqual(file.name, "renamedFile.json")
      XCTAssertEqual(file.path, folder.path + "renamedFile.json")
      XCTAssertEqual(file.extension, "json")
    }
  }

  internal func testRenamingFolder() {
    performTest {
      let subfolder = try folder.createSubfolder(named: "folder")
      try subfolder.rename(to: "renamedFolder")
      XCTAssertEqual(subfolder.name, "renamedFolder")
      XCTAssertEqual(subfolder.path, folder.path + "renamedFolder/")
    }
  }

  internal func testEmptyingFolder() {
    performTest {
      try folder.createFile(named: "A")
      try folder.createFile(named: "B")
      XCTAssertEqual(folder.files.count(), 2)

      try folder.empty()
      XCTAssertEqual(folder.files.count(), 0)
    }
  }

  internal func testEmptyingFolderWithHiddenFiles() {
    performTest {
      let subfolder = try folder.createSubfolder(named: "folder")

      try subfolder.createFile(named: "A")
      try subfolder.createFile(named: ".B")
      XCTAssertEqual(subfolder.files.includingHidden.count(), 2)

      // Per default, hidden files should not be deleted
      try subfolder.empty()
      XCTAssertEqual(subfolder.files.includingHidden.count(), 1)

      try subfolder.empty(includingHidden: true)
      XCTAssertEqual(folder.files.count(), 0)
    }
  }

  internal func testCheckingEmptyFolders() {
    performTest {
      let emptySubfolder = try folder.createSubfolder(named: "1")
      XCTAssertTrue(emptySubfolder.isEmpty())

      let subfolderWithFile = try folder.createSubfolder(named: "2")
      try subfolderWithFile.createFile(named: "A")
      XCTAssertFalse(subfolderWithFile.isEmpty())

      let subfolderWithHiddenFile = try folder.createSubfolder(named: "3")
      try subfolderWithHiddenFile.createFile(named: ".B")
      XCTAssertTrue(subfolderWithHiddenFile.isEmpty())
      XCTAssertFalse(subfolderWithHiddenFile.isEmpty(includingHidden: true))

      let subfolderWithFolder = try folder.createSubfolder(named: "3")
      try subfolderWithFolder.createSubfolder(named: "4")
      XCTAssertFalse(subfolderWithFile.isEmpty())
    }
  }
}
