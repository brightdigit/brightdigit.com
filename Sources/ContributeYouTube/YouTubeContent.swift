// swift-format-ignore-file
// swiftlint:disable all
import Foundation
import SwiftTube
import Contribute

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum YouTubeContent: ContentType {
  public typealias SourceType = Source
  public typealias MarkdownExtractorType = MarkdownExtractor
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

public extension YouTubeContent {
  /// Fetches every video in the request's playlist via the async
  /// swift-openapi-generator `YouTubeClient`, mapping each into a `Source`.
  static func videos(
    byRequest request: YouTubePlaylistRequest
  ) async throws -> [SourceType] {
    let client = YouTubeClient(apiKey: request.apiKey)
    let videos = try await client.videos(forPlaylistID: request.playlistID)

    return try videos.map { video in
      guard let id = video.id else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .id)
      }
      guard let title = video.title?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .snippetTitle)
      }
      guard let description = video.description else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .description)
      }
      guard let durationString = video.duration else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .duration)
      }
      guard let publishedAt = video.publishedAt else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .publishedAt)
      }
      guard let imageUrl = video.standardThumbnailURL else {
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
