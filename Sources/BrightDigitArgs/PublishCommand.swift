import ArgumentParser
import BrightDigitSite
import Publish

extension BrightDigitSiteCommand {
  public struct PublishCommand: AsyncParsableCommand {
    internal enum Mode: String, ExpressibleByArgument {
      case drafts, production
    }

    public static let configuration = CommandConfiguration(commandName: "publish")

    @Option internal var mode: Mode

    public init() {}

    public func run() async throws {
      try await BrightDigitSite().publish(includeDrafts: mode == .drafts)
    }
  }
}
