//
//  Import.PodcastCommand.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import BrightDigitPodcast
import ConfigKeyKit
import Configuration
import Contribute
import ContributeRSS
import ContributeYouTube
import Foundation
import SyndiKit

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Import.PodcastCommand {
  /// Resolved configuration for the `import podcast` command.
  public struct Config: ConfigurationParseable {
    public typealias ConfigReader = Configuration.ConfigReader
    public typealias BaseConfig = Never

    internal let playlistID: String
    internal let youtubeAPIKey: String
    internal let rss: URL
    internal let exportMarkdownDirectory: String
    internal let overwriteExisting: Bool
    internal let includeMissingPrevious: Bool

    public init(
      configuration reader: Configuration.ConfigReader,
      base _: Never?
    ) async throws {
      self.playlistID = reader.read(Keys.playlistID)

      guard let youtubeAPIKey = reader.read(Keys.youtubeAPIKey) else {
        throw CommandError.missingRequiredOption("--youtube-api-key")
      }
      self.youtubeAPIKey = youtubeAPIKey

      let rssString = reader.read(Keys.rss)
      guard let rss = URL(string: rssString) else {
        throw CommandError.invalidURL(rssString)
      }
      self.rss = rss

      guard let exportMarkdownDirectory = reader.read(Keys.exportMarkdownDirectory)
      else {
        throw CommandError.missingRequiredOption("--export-markdown-directory")
      }
      self.exportMarkdownDirectory = exportMarkdownDirectory

      self.overwriteExisting = reader.read(Keys.overwriteExisting)
      self.includeMissingPrevious = reader.read(Keys.includeMissingPrevious)
    }
  }

  private enum Keys {
    static let playlistID = ConfigKey(
      "playlist-id",
      default: "PLmpJxPaZbSnBvpnEdaX78wSM1d9BVvMfI"
    )
    static let youtubeAPIKey = OptionalConfigKey<String>(
      "youtube-api-key"
    )
    static let rss = ConfigKey(
      "rss",
      default: "https://feeds.transistor.fm/empowerapps-show"
    )
    static let exportMarkdownDirectory = OptionalConfigKey<String>(
      "export-markdown-directory"
    )
    static let overwriteExisting = ConfigKey(
      "overwrite-existing", default: false
    )
    static let includeMissingPrevious = ConfigKey(
      "include-missing-previous", default: false
    )
  }

  private static let youtubeIDRegex: NSRegularExpression = {
    do {
      return try NSRegularExpression(
        pattern:
          #"(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)"#
          + #"([A-Za-z0-9_-]{11})"#,
        options: []
      )
    } catch {
      preconditionFailure("Invalid youtubeIDRegex pattern: \(error)")
    }
  }()

  /// Extracts YouTube video ids (in order, de-duplicated) from show-notes HTML.
  ///
  /// The RSS episode body embeds the episode's `…/watch?v=<id>` link, which is a
  /// more reliable join key than the title (RSS and YouTube titles can differ —
  /// e.g. `Peter Witham` vs `@PeterWitham`).
  internal static func youtubeIDs(in html: String) -> [String] {
    let range = NSRange(html.startIndex..., in: html)
    var ids: [String] = []
    for match in youtubeIDRegex.matches(in: html, options: [], range: range) {
      guard let captured = Range(match.range(at: 1), in: html) else {
        continue
      }
      let id = String(html[captured])
      if !ids.contains(id) {
        ids.append(id)
      }
    }
    return ids
  }

  internal static func episodesBasedOn(
    rssItems: [RSSContent.Source],
    videoDurations: VideoDurations,
    videosByID: VideoDurations
  ) throws -> [BrightDigitPodcastSource] {
    try BrightDigitPodcastSource
      .episodesBasedOn(
        rssItems: rssItems
      ) { rssItem in
        // Prefer matching by the YouTube video id embedded in the show-notes.
        for id in youtubeIDs(in: rssItem.content) where videosByID[id] != nil {
          return videosByID[id]
        }
        // Fall back to an exact-title match.
        let title = rssItem.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let video = videoDurations[title] {
          return video
        }
        // No video at all: return nil so `episodesBasedOn` throws
        // `MediaError.missingVideoForEpisode` and the import fails loudly rather
        // than silently dropping the episode.
        return nil
      }
  }

  private static func videoIndices(
    config: Config
  ) async throws -> (durations: VideoDurations, byID: VideoDurations) {
    let videos = try await YouTubeContent.videos(
      byRequest: .init(
        apiKey: config.youtubeAPIKey,
        playlistID: config.playlistID
      )
    )
    let videoDurations = try YouTubeContent.videoDurations(videos)
    let videosByID = Dictionary(
      videos.map { ($0.youtubeID, $0) },
      uniquingKeysWith: { first, _ in first }
    )
    return (videoDurations, videosByID)
  }

  public func execute() async throws {
    let contentPathURL = URL(fileURLWithPath: config.exportMarkdownDirectory)

    let podcastEpisodes = try RSSContent.items(from: config.rss) { item in
      guard let link = item.link else {
        throw RSSError.missingFieldFromPodcastEpisode(
          String(describing: item), .link
        )
      }
      return link.lastPathComponent
    }
    let (videoDurations, videosByID) = try await Self.videoIndices(config: config)

    let episodes: [BrightDigitPodcastSource] =
      try Self.episodesBasedOn(
        rssItems: podcastEpisodes,
        videoDurations: videoDurations,
        videosByID: videosByID
      )
      .sorted(by: { lhs, rhs in lhs.episodeNo < rhs.episodeNo })

    let options: MarkdownContentBuilderOptions = .init(
      shouldOverwriteExisting: config.overwriteExisting,
      includeMissingPrevious: config.includeMissingPrevious
    )

    try BrightDigitPodcast.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      using: Import.markdownGenerator.markdown(fromHTML:),
      options: options
    )
  }
}

extension Import {
  /// ConfigKeyKit-based command for importing podcast episodes (issue #44).
  ///
  /// Registers under the two-token name `import podcast` and is dispatched by
  /// ``CommandDispatcher``. Pulls episodes from the Transistor RSS feed, enriches
  /// them with YouTube video durations, and writes Markdown episode files.
  public struct PodcastCommand: ConfigKeyKit.Command {
    public static let commandName = "import podcast"
    public static let abstract =
      "Command for importing a podcast into the BrightDigit site."
    public static let helpText = """
      OVERVIEW: Command for importing a podcast into the BrightDigit site.

      USAGE: brightdigitwg import podcast --youtube-api-key <key> \
      --export-markdown-directory <dir> [--playlist-id <id>] [--rss <url>] \
      [--overwrite-existing] [--include-missing-previous]

      OPTIONS:
        --playlist-id <id>                YouTube playlist ID.
        --youtube-api-key <key>           YouTube API key. (required)
        --rss <url>                       Podcast RSS feed URL.
        --export-markdown-directory <dir> Destination directory for markdown files. \
      (required)
        --overwrite-existing              Overwrite existing markdown files.
        --include-missing-previous        Include episodes missing a previous entry.
        -h, --help                        Show help information.

      Each option may also be supplied via an uppercased, underscore-separated
      environment variable (e.g. YOUTUBE_API_KEY).
      """

    private let config: Config

    public init(config: Config) {
      self.config = config
    }
  }
}

extension RSSContent.Source: AudioPodcastItem {
}

extension YouTubeContent.Source: VideoYouTubeItem {
}
