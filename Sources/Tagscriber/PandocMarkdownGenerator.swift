import Foundation
import ShellOut
import Contribute

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public extension PandocMarkdownGenerator {
  init() {
    self.init(shellOut: Self.defaultShellOut(to:arguments:))
  }

  static func defaultShellOut(to command: String, arguments: [String]) throws -> String {
    try ShellOut.shellOut(to: command, arguments: arguments)
  }
}
