import ArgumentParser
import BrightDigitPodcast
import BrightDigitSite
import Foundation

extension BrightDigitSiteCommand {
  public struct URLCommand: ParsableCommand {
    internal struct Podcast: ParsableCommand {
      @Option(help: "Base URL")
      internal var baseURL: URL = BrightDigitSite.SiteInfo.url

      @Option(help: "Base URL Path")
      internal var basePath: String = BrightDigitSite.SectionID.episodes.rawValue

      @Option(help: "Episode Number")
      internal var episodeNumber: Int

      @Option(help: "Episode Title")
      internal var episodeTitle: String

      internal init() {}

      internal func run() throws {
        let fileName = BrightDigitPodcast.fileNameWithoutExtensionForEpisode(
          withNumber: episodeNumber, title: episodeTitle)
        let url = baseURL.appendingPathComponent(basePath).appendingPathComponent(
          fileName)
        print(url)
      }
    }

    public static let configuration = CommandConfiguration(
      commandName: "url",
      abstract: "Command for previewing urls for the BrightDigit site.",
      subcommands: [Podcast.self]
    )

    public init() {}
  }
}
