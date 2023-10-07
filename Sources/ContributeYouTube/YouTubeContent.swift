import Prch
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
        throw YoutubeError.missingFieldForVideo(video, .id)
      }
      guard let title = video.snippet?.title?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        throw YoutubeError.missingFieldForVideo(video, .snippetTitle)
      }
      guard let description = video.snippet?.description else {
        throw YoutubeError.missingFieldForVideo(video, .description)
      }
      guard let durationString = video.contentDetails?.duration else {
        throw YoutubeError.missingFieldForVideo(video, .duration)
      }
      guard let publishedAt = video.snippet?.publishedAt else {
        throw YoutubeError.missingFieldForVideo(video, .publishedAt)
      }
      guard let imageUrl = video.snippet?.thumbnails?.standard?.url else {
        throw YoutubeError.missingFieldForVideo(video, .thumbnailUrl)
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
              forVideos: [existingVideo, video]
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
