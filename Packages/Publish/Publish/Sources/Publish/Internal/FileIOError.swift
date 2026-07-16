/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct FileIOError: Error {
  internal var path: Path
  internal var reason: Reason
}

extension FileIOError {
  internal enum Reason {
    case rootFolderNotFound
    case folderNotFound
    case folderCreationFailed
    case folderCopyingFailed
    case fileNotFound
    case fileCreationFailed
    case fileCouldNotBeRead
    case fileCopyingFailed
  }
}

extension FileIOError: PublishingErrorConvertible {
  internal func publishingError(forStepNamed stepName: String?) -> PublishingError {
    PublishingError(
      stepName: stepName,
      path: path,
      infoMessage: infoMessage,
      underlyingError: underlyingError
    )
  }
}

extension FileIOError {
  fileprivate var infoMessage: String {
    switch reason {
    case .rootFolderNotFound:
      return "The project's root folder could not be found"
    case .folderNotFound:
      return "Folder not found"
    case .folderCreationFailed:
      return "Failed to create folder"
    case .folderCopyingFailed:
      return "The folder could not be copied"
    case .fileNotFound:
      return "File not found"
    case .fileCreationFailed:
      return "Failed to create file"
    case .fileCouldNotBeRead:
      return "The file could not be read"
    case .fileCopyingFailed:
      return "The file could not be copied"
    }
  }

  fileprivate var underlyingError: Error? {
    nil
  }
}
