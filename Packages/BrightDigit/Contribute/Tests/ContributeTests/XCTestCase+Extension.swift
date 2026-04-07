import Contribute
import XCTest

extension XCTestCase {
  internal func assertThrowableBlock(
    expectedError: TestError,
    _ throwableBlock: () throws -> Any
  ) {
    let expectation = XCTestExpectation()

    XCTAssertThrowsError(try throwableBlock()) { actualError in
      print(actualError)
      guard
        let actualError = actualError as? TestError,
        actualError == expectedError else {
        XCTFail("Expected error of type \(expectedError)")
        return
      }

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 0.100)
  }
}

extension XCTestCase {
  internal func runFileURLDownloaderLocally(
    with fileManager: FileManagerSpy,
    and networkManager: NetworkManagerSpy,
    allowOverwrite: Bool,
    _ completion: @escaping (_ expectedError: Error?) -> Void = { _ in }
  ) {
    runFileURLDownloader(
      with: fileManager,
      and: networkManager,
      fromURL: .temporaryDirURL,
      allowOverwrite: allowOverwrite,
      completion
    )
  }

  internal func runFileURLDownloader(
    with fileManager: FileManagerSpy,
    and networkManager: NetworkManagerSpy,
    fromURL: URL,
    allowOverwrite: Bool,
    _ completion: @escaping (_ expectedError: Error?) -> Void = { _ in }
  ) {
    FileURLDownloader(
      networkManager: networkManager,
      fileManager: fileManager
    ).download(
      from: fromURL,
      to: .temporaryDirURL,
      allowOverwrite: allowOverwrite,
      completion
    )
  }

  internal func assertFileURLDownloaderLocally(
    with fileManager: FileManagerSpy,
    and networkManager: NetworkManagerSpy,
    allowOverwrite: Bool,
    expectedError: FileManagerTestError
  ) {
    let expectation = XCTestExpectation()

    runFileURLDownloaderLocally(
      with: fileManager,
      and: networkManager,
      allowOverwrite: allowOverwrite
    ) { actualError in
      guard
        let actualError = actualError as? FileManagerTestError,
        actualError == expectedError
      else {
        XCTFail("Expected failed \(expectedError.rawValue)")
        return
      }

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 0.100)
  }
}
