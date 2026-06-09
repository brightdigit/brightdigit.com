import ArgumentParser
import Contribute
import Foundation
import Publish
import SyndiKit
import Tagscriber

public extension BrightDigitSiteCommand {
  struct ImportCommand: ParsableCommand {
    nonisolated(unsafe) public static let markdownGenerator = PandocMarkdownGenerator()

    public init() {}
    nonisolated(unsafe) public static let configuration = CommandConfiguration(
      commandName: "import",
      abstract: "Command for import into the BrightDigit site.",
      subcommands: [WordPress.self, Podcast.self, Mailchimp.self]
    )
  }

}
