import Foundation

internal enum FileManagerTestError: String, Error, Equatable, CaseIterable {
  case createDirectory
  case copyItem
  case removeItem
}
