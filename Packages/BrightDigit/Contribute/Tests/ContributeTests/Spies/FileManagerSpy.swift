import Contribute
import Foundation

internal enum FileManagerTestError: String, Error, Equatable, CaseIterable {
  case createDirectory
  case copyItem
  case removeItem
}

internal final class FileManagerSpy: FileManagerProtocol {
  internal static var successfulDirectoryCreate: Self {
    .init(createDirectoryResult: .success(()))
  }

  internal private(set) var createDirectoryIsCalled: Bool = false
  internal private(set) var fileExistsIsCalled: Bool = false
  internal private(set) var copyItemIsCalled: Bool = false
  internal private(set) var removeItemIsCalled: Bool = false

  private var createDirectoryResult: Result<Void, FileManagerTestError>?
  private var fileExistsResult: Result<Bool, Never>?
  private var copyItemResult: Result<Void, FileManagerTestError>?
  private var removeItemResult: Result<Void, FileManagerTestError>?

  internal init(
    createDirectoryResult: Result<Void, FileManagerTestError>? = nil,
    fileExistsResult: Result<Bool, Never>? = nil,
    copyItemResult: Result<Void, FileManagerTestError>? = nil,
    removeItemResult: Result<Void, FileManagerTestError>? = nil
  ) {
    self.createDirectoryResult = createDirectoryResult
    self.fileExistsResult = fileExistsResult
    self.copyItemResult = copyItemResult
    self.removeItemResult = removeItemResult
  }

  internal func createDirectory(
    at _: URL,
    withIntermediateDirectories _: Bool,
    attributes _: [FileAttributeKey: Any]?
  ) throws {
    createDirectoryIsCalled = true
    try createDirectoryResult?.get()
  }

  internal func fileExists(atPath _: String) -> Bool {
    fileExistsIsCalled = true

    guard let fileExists = try? fileExistsResult?.get() else {
      return false
    }

    return fileExists
  }

  internal func copyItem(at _: URL, to _: URL) throws {
    copyItemIsCalled = true
    try copyItemResult?.get()
  }

  internal func removeItem(at _: URL) throws {
    removeItemIsCalled = true
    try removeItemResult?.get()
  }
}
