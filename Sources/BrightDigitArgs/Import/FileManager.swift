import Foundation

extension FileManager {
  public var currentDirectoryURL: URL {
    URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
  }
}
