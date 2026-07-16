//
//  FilesTests+Files.swift
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
  internal func testCreatingFileAtPath() {
    performTest {
      let path = "a/b/c.txt"

      XCTAssertFalse(folder.containsFile(at: path))
      try folder.createFile(at: path, contents: Data("Hello".utf8))

      XCTAssertTrue(folder.containsFile(at: path))
      XCTAssertTrue(folder.containsSubfolder(named: "a"))
      XCTAssertTrue(folder.containsSubfolder(at: "a/b"))

      let file = try folder.createFileIfNeeded(at: path)
      XCTAssertEqual(try file.readAsString(), "Hello")
    }
  }

  internal func testCreatingFileIfNeededAtPath() {
    performTest {
      let path = "a/b/c.txt"

      XCTAssertFalse(folder.containsFile(at: path))
      var file = try folder.createFileIfNeeded(at: path, contents: Data("Hello".utf8))

      XCTAssertTrue(folder.containsFile(at: path))
      XCTAssertTrue(folder.containsSubfolder(named: "a"))
      XCTAssertTrue(folder.containsSubfolder(at: "a/b"))

      file = try folder.createFileIfNeeded(at: path, contents: Data())
      XCTAssertEqual(try file.readAsString(), "Hello")
    }
  }

  internal func testDroppingLeadingSlashWhenCreatingFileAtPath() {
    performTest {
      let path = "/a/b/c.txt"

      XCTAssertFalse(folder.containsFile(at: path))
      try folder.createFile(at: path, contents: Data("Hello".utf8))

      XCTAssertTrue(folder.containsFile(at: path))
      XCTAssertTrue(folder.containsSubfolder(named: "a"))
      XCTAssertTrue(folder.containsSubfolder(at: "/a/b"))

      let file = try folder.createFileIfNeeded(at: path)
      XCTAssertEqual(try file.readAsString(), "Hello")
    }
  }

  internal func testReadingFileAsString() {
    performTest {
      let file = try folder.createFile(named: "string", contents: Data("Hello".utf8))
      try XCTAssertEqual(file.readAsString(), "Hello")
    }
  }

  internal func testReadingFileAsInt() {
    performTest {
      let intFile = try folder.createFile(named: "int", contents: Data("\(7)".utf8))
      try XCTAssertEqual(intFile.readAsInt(), 7)

      let nonIntFile = try folder.createFile(
        named: "nonInt",
        contents: Data("Not an int".utf8)
      )
      try assert(nonIntFile.readAsInt(), throwsErrorOfType: ReadError.self)
    }
  }

  internal func testReadingFileWithTildePath() {
    performTest {
      try folder.createFile(named: "File")
      let file = try File(path: "~/.filesTest/File")
      try XCTAssertEqual(file.read(), Data())
      XCTAssertEqual(file.path, folder.path + "File")

      // Cleanup since we're performing a test in the actual home folder
      try file.delete()
    }
  }

  internal func testAccesingFileByPath() {
    performTest {
      let subfolderA = try folder.createSubfolder(named: "A")
      let subfolderB = try subfolderA.createSubfolder(named: "B")
      let file = try subfolderB.createFile(named: "C")
      try XCTAssertEqual(folder.file(at: "A/B/C"), file)
    }
  }

  internal func testWritingDataToFile() {
    performTest {
      let file = try folder.createFile(named: "file")
      try XCTAssertEqual(file.read(), Data())

      let data = Data("New content".utf8)
      try file.write(data)
      try XCTAssertEqual(file.read(), data)
    }
  }

  internal func testWritingStringToFile() {
    performTest {
      let file = try folder.createFile(named: "file")
      try XCTAssertEqual(file.read(), Data())

      try file.write("New content")
      try XCTAssertEqual(file.read(), Data("New content".utf8))
    }
  }

  internal func testAppendingDataToFile() {
    performTest {
      let file = try folder.createFile(named: "file")
      let data = Data("Old content\n".utf8)
      try file.write(data)

      let newData = Data("I'm the appended content 💯\n".utf8)
      try file.append(newData)
      try XCTAssertEqual(
        file.read(),
        Data("Old content\nI'm the appended content 💯\n".utf8)
      )
    }
  }

  internal func testAppendingStringToFile() {
    performTest {
      let file = try folder.createFile(named: "file")
      try file.write("Old content\n")

      let newString = "I'm the appended content 💯\n"
      try file.append(newString)
      try XCTAssertEqual(
        file.read(),
        Data("Old content\nI'm the appended content 💯\n".utf8)
      )
    }
  }

  internal func testCreateFileIfNeeded() {
    performTest {
      let fileA = try folder.createFileIfNeeded(
        withName: "file",
        contents: Data("Hello".utf8)
      )
      let fileB = try folder.createFileIfNeeded(
        withName: "file",
        contents: Data("World".utf8)
      )
      try XCTAssertEqual(fileA.readAsString(), "Hello")
      try XCTAssertEqual(fileA.read(), fileB.read())
    }
  }

  internal func testCreatingFileWithString() {
    performTest {
      let file = try folder.createFile(named: "file", contents: Data("Hello world".utf8))
      XCTAssertEqual(try file.readAsString(), "Hello world")
    }
  }
}
