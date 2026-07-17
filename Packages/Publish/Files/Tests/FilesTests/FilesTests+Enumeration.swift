//
//  FilesTests+Enumeration.swift
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
  internal func testEnumeratingFiles() {
    performTest {
      try folder.createFile(named: "1")
      try folder.createFile(named: "2")
      try folder.createFile(named: "3")

      // Hidden files should be excluded by default
      try folder.createFile(named: ".hidden")

      XCTAssertEqual(folder.files.names().sorted(), ["1", "2", "3"])
      XCTAssertEqual(folder.files.count(), 3)
    }
  }

  internal func testEnumeratingFilesIncludingHidden() {
    performTest {
      let subfolder = try folder.createSubfolder(named: "folder")
      try subfolder.createFile(named: ".hidden")
      try subfolder.createFile(named: "visible")

      let files = subfolder.files.includingHidden
      XCTAssertEqual(files.names().sorted(), [".hidden", "visible"])
      XCTAssertEqual(files.count(), 2)
    }
  }

  internal func testEnumeratingFilesRecursively() {
    performTest {
      let subfolder1 = try folder.createSubfolder(named: "1")
      let subfolder2 = try folder.createSubfolder(named: "2")

      let subfolder1A = try subfolder1.createSubfolder(named: "A")
      let subfolder1B = try subfolder1.createSubfolder(named: "B")

      let subfolder2A = try subfolder2.createSubfolder(named: "A")
      let subfolder2B = try subfolder2.createSubfolder(named: "B")

      try subfolder1.createFile(named: "File1")
      try subfolder1A.createFile(named: "File1A")
      try subfolder1B.createFile(named: "File1B")
      try subfolder2.createFile(named: "File2")
      try subfolder2A.createFile(named: "File2A")
      try subfolder2B.createFile(named: "File2B")

      let expectedNames = ["File1", "File1A", "File1B", "File2", "File2A", "File2B"]
      let sequence = folder.files.recursive
      XCTAssertEqual(sequence.names(), expectedNames)
      XCTAssertEqual(sequence.count(), 6)
    }
  }

  internal func testEnumeratingSubfolders() {
    performTest {
      try folder.createSubfolder(named: "1")
      try folder.createSubfolder(named: "2")
      try folder.createSubfolder(named: "3")

      XCTAssertEqual(folder.subfolders.names(), ["1", "2", "3"])
      XCTAssertEqual(folder.subfolders.count(), 3)
    }
  }

  internal func testEnumeratingSubfoldersRecursively() {
    performTest {
      let subfolder1 = try folder.createSubfolder(named: "1")
      let subfolder2 = try folder.createSubfolder(named: "2")

      try subfolder1.createSubfolder(named: "1A")
      try subfolder1.createSubfolder(named: "1B")

      try subfolder2.createSubfolder(named: "2A")
      try subfolder2.createSubfolder(named: "2B")

      let expectedNames = ["1", "1A", "1B", "2", "2A", "2B"]
      let sequence = folder.subfolders.recursive
      XCTAssertEqual(sequence.names().sorted(), expectedNames)
      XCTAssertEqual(sequence.count(), 6)
    }
  }

  internal func testRenamingFoldersWhileEnumeratingSubfoldersRecursively() {
    performTest {
      let subfolder1 = try folder.createSubfolder(named: "1")
      let subfolder2 = try folder.createSubfolder(named: "2")

      try subfolder1.createSubfolder(named: "1A")
      try subfolder1.createSubfolder(named: "1B")

      try subfolder2.createSubfolder(named: "2A")
      try subfolder2.createSubfolder(named: "2B")

      let sequence = folder.subfolders.recursive

      for folder in sequence {
        try folder.rename(to: "Folder " + folder.name)
      }

      let expectedNames = [
        "Folder 1", "Folder 1A", "Folder 1B", "Folder 2", "Folder 2A", "Folder 2B",
      ]

      XCTAssertEqual(sequence.names().sorted(), expectedNames)
      XCTAssertEqual(sequence.count(), 6)
    }
  }

  internal func testFirstAndLastInFileSequence() {
    performTest {
      try folder.createFile(named: "A")
      try folder.createFile(named: "B")
      try folder.createFile(named: "C")

      XCTAssertEqual(folder.files.first?.name, "A")
      XCTAssertEqual(folder.files.last()?.name, "C")
    }
  }

  internal func testConvertingFileSequenceToRecursive() {
    performTest {
      try folder.createFile(named: "A")
      try folder.createFile(named: "B")

      let subfolder = try folder.createSubfolder(named: "1")
      try subfolder.createFile(named: "1A")

      let names = folder.files.recursive.names()
      XCTAssertEqual(names, ["A", "B", "1A"])
    }
  }
}
