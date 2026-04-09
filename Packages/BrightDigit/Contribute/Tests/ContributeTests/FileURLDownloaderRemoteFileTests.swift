@testable import Contribute
import XCTest

internal final class FileURLDownloaderRemoteFileTests: XCTestCase {
  private let fileManager = FileManagerSpy()

  internal func testSuccessfulNetworkCall() throws {
    let networkManager = NetworkManagerSpy.success

    let sut = FileURLDownloader(networkManager: networkManager, fileManager: fileManager)

    let expectation = XCTestExpectation()

    sut.download(
      from: try makeURL(from: "https://www.google.com"),
      to: .temporaryDirURL,
      allowOverwrite: true
    ) { error in
      if error == nil {
        expectation.fulfill()
        return
      }

      XCTFail("Expected successful network call")
    }

    wait(for: [expectation], timeout: 0.100)
  }

  internal func testFailedNetworkCall() throws {
    let networkManager = NetworkManagerSpy.failure

    let sut = FileURLDownloader(networkManager: networkManager, fileManager: fileManager)

    let expectation = XCTestExpectation()

    sut.download(
      from: try makeURL(from: "https://www.google.com"),
      to: .temporaryDirURL,
      allowOverwrite: true
    ) { error in
      guard error != nil else {
        XCTFail("Expected failed network call")
        return
      }

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 0.100)
  }

  // MARK: - Helpers

  private func makeURL(from string: String) throws -> URL {
    guard let url = URL(string: string) else {
      throw TestError.makeURL
    }

    return url
  }
}
