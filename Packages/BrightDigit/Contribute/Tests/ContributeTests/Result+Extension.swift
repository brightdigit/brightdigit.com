import Foundation

extension Result where Success == Bool, Failure == Never {
  internal static var fileExistsResult: Result<Bool, Never> { .success(true) }
  internal static var fileDoesNotExistsResult: Result<Bool, Never> { .success(false) }
}
