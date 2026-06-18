import ArgumentParser
import Contribute
import Foundation
import Publish
import SyndiKit

extension BrightDigitSiteCommand {
  public struct ImportCommand: ParsableCommand {
    public static let markdownGenerator = SwiftSoupMarkdownGenerator()
    public static let configuration = CommandConfiguration(
      commandName: "import",
      abstract: "Command for import into the BrightDigit site.",
      subcommands: [WordPress.self, Podcast.self, Mailchimp.self]
    )

    public init() {}
  }
}
