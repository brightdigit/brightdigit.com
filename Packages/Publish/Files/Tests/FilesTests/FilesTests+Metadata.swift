//
//  FilesTests+Metadata.swift
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
  internal func testReadingFileWithRelativePath() {
    performTest {
      try folder.createFile(named: "file")

      // Make sure we're not already in the file's parent directory
      XCTAssertNotEqual(FileManager.default.currentDirectoryPath, folder.path)

      XCTAssertTrue(FileManager.default.changeCurrentDirectoryPath(folder.path))
      let file = try File(path: "file")
      try XCTAssertEqual(file.read(), Data())
    }
  }

  internal func testReadingFileFromCurrentFoldersParent() {
    performTest {
      let subfolder = try folder.createSubfolder(named: "folder")
      let file = try folder.createFile(named: "file")

      // Move to the subfolder
      XCTAssertNotEqual(FileManager.default.currentDirectoryPath, subfolder.path)
      XCTAssertTrue(FileManager.default.changeCurrentDirectoryPath(subfolder.path))

      try XCTAssertEqual(File(path: "../file"), file)
    }
  }

  internal func testReadingFileWithMultipleParentReferencesWithinPath() {
    performTest {
      let subfolderA = try folder.createSubfolder(named: "A")
      try folder.createSubfolder(named: "B")
      let subfolderC = try folder.createSubfolder(named: "C")
      let file = try subfolderC.createFile(named: "file")

      try XCTAssertEqual(File(path: subfolderA.path + "../B/../C/file"), file)
    }
  }

  internal func testAccessingSubfolderByPath() {
    performTest {
      let subfolderA = try folder.createSubfolder(named: "A")
      let subfolderB = try subfolderA.createSubfolder(named: "B")
      let subfolderC = try subfolderB.createSubfolder(named: "C")
      try XCTAssertEqual(folder.subfolder(at: "A/B/C"), subfolderC)
    }
  }

  internal func testModificationDate() {
    performTest {
      let subfolder = try folder.createSubfolder(named: "Folder")
      XCTAssertTrue(subfolder.modificationDate.map(Calendar.current.isDateInToday) ?? false)

      let file = try folder.createFile(named: "File")
      XCTAssertTrue(file.modificationDate.map(Calendar.current.isDateInToday) ?? false)
    }
  }

  internal func testParent() {
    performTest {
      try XCTAssertEqual(folder.createFile(named: "test").parent, folder)

      let subfolder = try folder.createSubfolder(named: "subfolder")
      XCTAssertEqual(subfolder.parent, folder)
      try XCTAssertEqual(subfolder.createFile(named: "test").parent, subfolder)
    }
  }

  internal func testRootFolderParentIsNil() {
    performTest {
      try XCTAssertNil(Folder(path: Self.rootPath).parent)
    }
  }

  internal func testRootSubfolderParentIsRoot() {
    performTest {
      let rootFolder = try Folder(path: Self.rootPath)
      let subfolder = rootFolder.subfolders.first
      XCTAssertEqual(subfolder?.parent, rootFolder)
    }
  }

  internal func testFileDescription() {
    performTest {
      let file = try folder.createFile(named: "file")
      XCTAssertEqual(file.description, "File(name: file, path: \(folder.path)file)")
    }
  }

  internal func testFolderDescription() {
    performTest {
      let subfolder = try folder.createSubfolder(named: "folder")
      XCTAssertEqual(subfolder.description, "Folder(name: folder, path: \(folder.path)folder/)")
    }
  }

  internal func testFilesDescription() {
    performTest {
      let fileA = try folder.createFile(named: "fileA")
      let fileB = try folder.createFile(named: "fileB")
      XCTAssertEqual(folder.files.description, "\(fileA.description)\n\(fileB.description)")
    }
  }

  internal func testSubfoldersDescription() {
    performTest {
      let folderA = try folder.createSubfolder(named: "folderA")
      let folderB = try folder.createSubfolder(named: "folderB")
      XCTAssertEqual(
        folder.subfolders.description,
        "\(folderA.description)\n\(folderB.description)"
      )
    }
  }

  internal func testAccessingHomeFolder() {
    XCTAssertNotNil(Folder.home)
  }

  internal func testAccessingCurrentWorkingDirectory() {
    performTest {
      let folder = try Folder(path: "")
      // `folder.path` is in canonical (forward-slash) form; the current directory
      // reported by FileManager uses the platform's native separator on Windows.
      XCTAssertEqual(canonical(FileManager.default.currentDirectoryPath) + "/", folder.path)
      XCTAssertEqual(Folder.current, folder)
    }
  }

  internal func testNameExcludingExtensionWithLongFileName() {
    performTest {
      let file = try folder.createFile(named: "AVeryLongFileName.png")
      XCTAssertEqual(file.nameExcludingExtension, "AVeryLongFileName")
    }
  }

  internal func testNameExcludingExtensionWithoutExtension() {
    performTest {
      let file = try folder.createFile(named: "File")
      let subfolder = try folder.createSubfolder(named: "Subfolder")

      XCTAssertEqual(file.nameExcludingExtension, "File")
      XCTAssertEqual(subfolder.nameExcludingExtension, "Subfolder")
    }
  }

  internal func testRelativePaths() {
    performTest {
      let file = try folder.createFile(named: "FileA")
      let subfolder = try folder.createSubfolder(named: "Folder")
      let fileInSubfolder = try subfolder.createFile(named: "FileB")

      XCTAssertEqual(file.path(relativeTo: folder), "FileA")
      XCTAssertEqual(subfolder.path(relativeTo: folder), "Folder")
      XCTAssertEqual(fileInSubfolder.path(relativeTo: folder), "Folder/FileB")
    }
  }

  internal func testRelativePathIsAbsolutePathForNonParent() {
    performTest {
      let file = try folder.createFile(named: "FileA")
      let subfolder = try folder.createSubfolder(named: "Folder")

      XCTAssertEqual(file.path(relativeTo: subfolder), file.path)
    }
  }

  internal func testErrorDescriptions() {
    let missingError = FilesError(
      path: "/some/path",
      reason: LocationErrorReason.missing
    )

    XCTAssertEqual(
      missingError.description,
      """
      Files encountered an error at '/some/path'.
      Reason: missing
      """
    )

    let encodingError = FilesError(
      path: "/some/path",
      reason: WriteErrorReason.stringEncodingFailed("Hello")
    )

    XCTAssertEqual(
      encodingError.description,
      """
      Files encountered an error at '/some/path'.
      Reason: stringEncodingFailed(\"Hello\")
      """
    )
  }
}
