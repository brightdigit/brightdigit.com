import Foundation

public struct PassthroughMarkdownGenerator: MarkdownGenerator {
  public static let shared = PassthroughMarkdownGenerator()
  private init() {}
  public func markdown(fromHTML htmlString: String) throws -> String {
    htmlString
  }
}
