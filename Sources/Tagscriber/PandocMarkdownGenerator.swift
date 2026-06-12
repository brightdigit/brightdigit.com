import Contribute
import Foundation
import ShellOut

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension PandocMarkdownGenerator {
  public init() {
    self.init(shellOut: Self.defaultShellOut(to:arguments:))
  }

  public static func defaultShellOut(to command: String, arguments: [String]) throws
    -> String
  {
    try ShellOut.shellOut(to: command, arguments: arguments)
  }
}
