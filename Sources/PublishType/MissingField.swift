import Foundation
import Plot
import Publish

public protocol MissingField: CustomStringConvertible, Sendable {
  static var typeName: String { get }
  var fieldName: String { get }
}

extension MissingField {
  public var description: String {
    [Self.typeName, fieldName].joined(separator: ".")
  }
}
