import ArgumentParser
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct BrightDigitSiteCommand: AsyncParsableCommand {
  public init() {}

  nonisolated(unsafe) public static let configuration = CommandConfiguration(
    abstract: "Command for maintaining the BrightDigit site.",
    subcommands: [PublishCommand.self, ImportCommand.self, URLCommand.self],
    defaultSubcommand: PublishCommand.self
  )
}

extension URL: ExpressibleByArgument {
  public init?(argument: String) {
    self.init(string: argument)
  }
}
