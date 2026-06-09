import Foundation

extension URLComponents {
  init(staticString: String) {
    guard let components = URLComponents(string: staticString) else {
      preconditionFailure("Invalid static URLComponents string: \(staticString)")
    }
    self = components
  }
}
