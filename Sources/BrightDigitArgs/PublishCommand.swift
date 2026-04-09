import ArgumentParser
import BrightDigitSite
import Publish

public extension BrightDigitSiteCommand {
  struct PublishCommand: AsyncParsableCommand {
    enum Mode: String, ExpressibleByArgument {
      case drafts, production
    }

    public static var configuration = CommandConfiguration(commandName: "publish")
    public init() {}

    @Option var mode: Mode

    public func run() async throws {
      try await BrightDigitSite().publish(includeDrafts: mode == .drafts)
    }
  }
}
