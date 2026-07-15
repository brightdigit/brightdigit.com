/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

internal struct Environment {
  private var values = [String: Any]()

  internal subscript<T>(key: EnvironmentKey<T>) -> T? {
    get { values["\(key.identifier)"] as? T }
    set { values["\(key.identifier)"] = newValue }
  }
}

extension Environment {
  internal final class Reference {
    internal var value: Environment?
  }

  internal struct Override {
    private let closure: (inout Environment) -> Void

    internal init<T>(key: EnvironmentKey<T>, value: T) {
      closure = { $0[key] = value }
    }

    internal func apply(to environment: inout Environment) {
      closure(&environment)
    }
  }
}
