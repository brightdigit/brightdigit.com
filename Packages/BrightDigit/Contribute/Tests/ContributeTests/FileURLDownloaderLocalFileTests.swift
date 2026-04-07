@testable import Contribute
import XCTest

internal final class FileURLDownloaderLocalFileTests: XCTestCase {
  private let networkManager = NetworkManagerSpy.success

  internal func testSuccessfulDirectoryCreate() {
    let fileManager = FileManagerSpy.successfulDirectoryCreate

    let sut = FileURLDownloader(networkManager: networkManager, fileManager: fileManager)

    sut.download(
      from: .temporaryDirURL,
      to: .temporaryDirURL,
      allowOverwrite: true
    ) { _ in
      // doing nothing
    }

    XCTAssertTrue(fileManager.createDirectoryIsCalled)
  }

  internal func testSuccessfulCopyItemWhenFileDoesNotExists() {
    let fileManager = FileManagerSpy(
      fileExistsResult: .fileDoesNotExistsResult,
      copyItemResult: .success(())
    )

    runFileURLDownloaderLocally(
      with: fileManager,
      and: networkManager,
      allowOverwrite: false
    )

    XCTAssertTrue(fileManager.createDirectoryIsCalled)
    XCTAssertTrue(fileManager.fileExistsIsCalled)
    XCTAssertTrue(fileManager.copyItemIsCalled)
    XCTAssertFalse(fileManager.removeItemIsCalled)
  }

  internal func testFailedCopyItemWhenFileDoesNotExists() {
    let expectedError = FileManagerTestError.copyItem

    let fileManager = FileManagerSpy(
      fileExistsResult: .fileDoesNotExistsResult,
      copyItemResult: .failure(expectedError)
    )

    assertFileURLDownloaderLocally(
      with: fileManager,
      and: networkManager,
      allowOverwrite: false,
      expectedError: expectedError
    )

    XCTAssertTrue(fileManager.createDirectoryIsCalled)
    XCTAssertTrue(fileManager.fileExistsIsCalled)
    XCTAssertTrue(fileManager.copyItemIsCalled)
    XCTAssertFalse(fileManager.removeItemIsCalled)
  }

  internal func testSuccessfulOverwriteWhenAllowExistedFileOverwrite() {
    let fileManager = FileManagerSpy(
      fileExistsResult: .fileExistsResult,
      copyItemResult: .success(()),
      removeItemResult: .success(())
    )

    runFileURLDownloaderLocally(
      with: fileManager,
      and: networkManager,
      allowOverwrite: true
    )

    XCTAssertTrue(fileManager.createDirectoryIsCalled)
    XCTAssertTrue(fileManager.fileExistsIsCalled)
    XCTAssertTrue(fileManager.removeItemIsCalled)
    XCTAssertTrue(fileManager.copyItemIsCalled)
  }

  internal func testFailedRemoveItemWhenAllowExistedFileOverwrite() {
    let expectedError = FileManagerTestError.removeItem

    let fileManager = FileManagerSpy(
      fileExistsResult: .fileExistsResult,
      copyItemResult: .success(()),
      removeItemResult: .failure(expectedError)
    )

    assertFileURLDownloaderLocally(
      with: fileManager,
      and: networkManager,
      allowOverwrite: true,
      expectedError: expectedError
    )

    XCTAssertTrue(fileManager.createDirectoryIsCalled)
    XCTAssertTrue(fileManager.fileExistsIsCalled)
    XCTAssertTrue(fileManager.removeItemIsCalled)
    XCTAssertFalse(fileManager.copyItemIsCalled)
  }

  internal func testFailedCopyItemWhenAllowExistedFileOverwrite() {
    let expectedError = FileManagerTestError.copyItem

    let fileManager = FileManagerSpy(
      fileExistsResult: .fileExistsResult,
      copyItemResult: .failure(expectedError),
      removeItemResult: .success(())
    )

    assertFileURLDownloaderLocally(
      with: fileManager,
      and: networkManager,
      allowOverwrite: true,
      expectedError: expectedError
    )

    XCTAssertTrue(fileManager.createDirectoryIsCalled)
    XCTAssertTrue(fileManager.fileExistsIsCalled)
    XCTAssertTrue(fileManager.removeItemIsCalled)
    XCTAssertTrue(fileManager.copyItemIsCalled)
  }
}
