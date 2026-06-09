import Foundation
import Plot
import Publish

public protocol MissingField: CustomStringConvertible, Sendable {
  static var typeName: String { get }
  var fieldName: String { get }
}

public extension MissingField {
  var description: String {
    [Self.typeName, fieldName].joined(separator: ".")
  }
}
