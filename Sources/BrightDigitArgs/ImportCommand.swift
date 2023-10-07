import ArgumentParser
import Contribute
import Foundation
import Publish
import SyndiKit
import Tagscriber

public extension BrightDigitSiteCommand {
  struct ImportCommand: ParsableCommand {
    public static let markdownGenerator = PandocMarkdownGenerator()

    public init() {}
    public static var configuration = CommandConfiguration(
      commandName: "import",
      abstract: "Command for import into the BrightDigit site.",
      subcommands: [WordPress.self, Podcast.self, Mailchimp.self]
    )
  }

}
