//
//  FilesTests.swift
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

internal class FilesTests: XCTestCase {
  // MARK: - Linux

  internal static let allTests = [
    ("testCreatingAndDeletingFile", testCreatingAndDeletingFile),
    ("testCreatingFileAtPath", testCreatingFileAtPath),
    (
      "testDroppingLeadingSlashWhenCreatingFileAtPath",
      testDroppingLeadingSlashWhenCreatingFileAtPath
    ),
    ("testCreatingAndDeletingFolder", testCreatingAndDeletingFolder),
    ("testCreatingSubfolderAtPath", testCreatingSubfolderAtPath),
    (
      "testDroppingLeadingSlashWhenCreatingSubfolderAtPath",
      testDroppingLeadingSlashWhenCreatingSubfolderAtPath
    ),
    ("testReadingFileAsString", testReadingFileAsString),
    ("testReadingFileAsInt", testReadingFileAsInt),
    ("testRenamingFile", testRenamingFile),
    ("testRenamingFileWithNameIncludingExtension", testRenamingFileWithNameIncludingExtension),
    ("testReadingFileWithRelativePath", testReadingFileWithRelativePath),
    ("testReadingFileWithTildePath", testReadingFileWithTildePath),
    ("testReadingFileFromCurrentFoldersParent", testReadingFileFromCurrentFoldersParent),
    (
      "testReadingFileWithMultipleParentReferencesWithinPath",
      testReadingFileWithMultipleParentReferencesWithinPath
    ),
    ("testRenamingFolder", testRenamingFolder),
    ("testAccesingFileByPath", testAccesingFileByPath),
    ("testAccessingSubfolderByPath", testAccessingSubfolderByPath),
    ("testEmptyingFolder", testEmptyingFolder),
    ("testEmptyingFolderWithHiddenFiles", testEmptyingFolderWithHiddenFiles),
    ("testCheckingEmptyFolders", testCheckingEmptyFolders),
    ("testMovingFiles", testMovingFiles),
    ("testCopyingFiles", testCopyingFiles),
    ("testCopyingFolders", testCopyingFolders),
    ("testEnumeratingFiles", testEnumeratingFiles),
    ("testEnumeratingFilesIncludingHidden", testEnumeratingFilesIncludingHidden),
    ("testEnumeratingFilesRecursively", testEnumeratingFilesRecursively),
    ("testEnumeratingSubfolders", testEnumeratingSubfolders),
    ("testEnumeratingSubfoldersRecursively", testEnumeratingSubfoldersRecursively),
    (
      "testRenamingFoldersWhileEnumeratingSubfoldersRecursively",
      testRenamingFoldersWhileEnumeratingSubfoldersRecursively
    ),
    ("testFirstAndLastInFileSequence", testFirstAndLastInFileSequence),
    ("testConvertingFileSequenceToRecursive", testConvertingFileSequenceToRecursive),
    ("testModificationDate", testModificationDate),
    ("testParent", testParent),
    ("testRootFolderParentIsNil", testRootFolderParentIsNil),
    ("testRootSubfolderParentIsRoot", testRootSubfolderParentIsRoot),
    ("testOpeningFileWithEmptyPathThrows", testOpeningFileWithEmptyPathThrows),
    ("testDeletingNonExistingFileThrows", testDeletingNonExistingFileThrows),
    ("testWritingDataToFile", testWritingDataToFile),
    ("testWritingStringToFile", testWritingStringToFile),
    ("testAppendingDataToFile", testAppendingDataToFile),
    ("testAppendingStringToFile", testAppendingStringToFile),
    ("testFileDescription", testFileDescription),
    ("testFolderDescription", testFolderDescription),
    ("testFilesDescription", testFilesDescription),
    ("testSubfoldersDescription", testSubfoldersDescription),
    ("testMovingFolderContents", testMovingFolderContents),
    ("testMovingFolderHiddenContents", testMovingFolderHiddenContents),
    ("testAccessingHomeFolder", testAccessingHomeFolder),
    ("testAccessingCurrentWorkingDirectory", testAccessingCurrentWorkingDirectory),
    ("testNameExcludingExtensionWithLongFileName", testNameExcludingExtensionWithLongFileName),
    ("testRelativePaths", testRelativePaths),
    ("testRelativePathIsAbsolutePathForNonParent", testRelativePathIsAbsolutePathForNonParent),
    ("testCreateFileIfNeeded", testCreateFileIfNeeded),
    ("testCreateFolderIfNeeded", testCreateFolderIfNeeded),
    ("testCreateSubfolderIfNeeded", testCreateSubfolderIfNeeded),
    ("testCreatingFileWithString", testCreatingFileWithString),
    ("testFolderContainsFile", testFolderContainsFile),
    ("testFolderContainsSubfolder", testFolderContainsSubfolder),
    ("testErrorDescriptions", testErrorDescriptions),
  ]

  // MARK: - Fixtures

  // The test folder is created in `setUp` before every test runs, so this
  // implicitly unwrapped optional is always populated while tests execute.
  // swiftlint:disable:next implicitly_unwrapped_optional
  internal var folder: Folder!

  // MARK: - XCTestCase

  override internal func setUp() {
    super.setUp()
    // Test scaffolding: the shared test folder must exist for every test, so
    // failing fast here is the desired behavior.
    // swiftlint:disable:next force_try
    folder = try! Folder.home.createSubfolderIfNeeded(withName: ".filesTest")
    // swiftlint:disable:next force_try
    try! folder.empty()
  }

  override internal func tearDown() {
    try? folder.delete()
    super.tearDown()
  }

  // MARK: - Utilities

  internal func performTest(closure: () throws -> Void) {
    do {
      try folder.empty()
      try closure()
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }
  }

  internal func assert<T, E: Error>(
    _ expression: @autoclosure () throws -> T,
    throwsErrorOfType expectedError: E.Type
  ) {
    do {
      _ = try expression()
      XCTFail("Expected error to be thrown")
    } catch {
      XCTAssertTrue(error is E)
    }
  }
}
