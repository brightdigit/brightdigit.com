// swift-format-ignore-file
// swiftlint:disable all
import Prch
import Foundation
import SwiftTube
import Contribute

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public enum YouTubeContent: ContentType {
  public typealias SourceType = Source
  public typealias MarkdownExtractorType = MarkdownExtractor
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public extension YouTubeContent {
  static func videos(byRequest request: YouTubePlaylistRequest) throws -> [SourceType] {
    let youtubeClient = Prch.Client(
      api: YouTube.API(),
      session: URLSession.shared
    )

    return try youtubeClient.videos(
      fromRequest: .init(
        apiKey: request.apiKey,
        playlistID: request.playlistID
      )
    )
    .map { video in
      guard let id = video.id else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .id)
      }
      guard let title = video.snippet?.title?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .snippetTitle)
      }
      guard let description = video.snippet?.description else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .description)
      }
      guard let durationString = video.contentDetails?.duration else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .duration)
      }
      guard let publishedAt = video.snippet?.publishedAt else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .publishedAt)
      }
      guard let imageUrl = video.snippet?.thumbnails?.standard?.url else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .thumbnailUrl)
      }
      return .init(
        title: title,
        description: description,
        youtubeID: id,
        duration: .init(iso6801: durationString),
        date: publishedAt,
        imageURL: URL(string: imageUrl)
      )
    }
  }

  static func videoDurations(_ videos: [SourceType]) throws -> VideoDurations {
    try videos
      .reduce(VideoDurations()) { dictionary, video in
        let title = video.title
        if let existingVideo = dictionary[title] {
          guard existingVideo == video else {
            throw YoutubeError.duplicateTitle(
              title,
              forVideos: [existingVideo, video].map { String(describing: $0) }
            )
          }
          return dictionary
        } else {
          var newDictionary = dictionary
          newDictionary[title] = video
          return newDictionary
        }
      }
  }
}
