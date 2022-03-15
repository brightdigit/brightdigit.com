public protocol TransistorRenderer {
  func render(Transistor: EmbeddedTransistor) throws -> String
}

public final class DefaultTransistorRenderer: TransistorRenderer {
  public init() {}
  public func render(Transistor: EmbeddedTransistor) throws -> String { Transistor.html }
}
