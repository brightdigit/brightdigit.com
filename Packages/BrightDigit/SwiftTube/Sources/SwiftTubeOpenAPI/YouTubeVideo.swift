import Foundation

/// A YouTube video, reduced to the fields the importer reads.
///
/// All fields are optional because the importer is responsible for validating
/// presence and emitting domain-specific errors; this type intentionally does
/// not throw.
public struct YouTubeVideo: Equatable, Sendable {
  /// The video id.
  public let id: String?
  /// The video title.
  public let title: String?
  /// The video description.
  public let description: String?
  /// ISO 8601 publish timestamp, as returned by the API (e.g. `2020-01-02T03:04:05Z`).
  public let publishedAt: String?
  /// ISO 8601 duration string (e.g. `PT1H2M3S`).
  public let duration: String?
  /// URL of the `standard` thumbnail, if present.
  public let standardThumbnailURL: String?

  /// Memberwise initializer.
  public init(
    id: String?,
    title: String?,
    description: String?,
    publishedAt: String?,
    duration: String?,
    standardThumbnailURL: String?
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.publishedAt = publishedAt
    self.duration = duration
    self.standardThumbnailURL = standardThumbnailURL
  }
}

extension YouTubeVideo {
  /// Maps a generated OpenAPI `Video` schema into the flat importer model.
  init(from video: Components.Schemas.Video) {
    self.init(
      id: video.id,
      title: video.snippet?.title,
      description: video.snippet?.description,
      publishedAt: video.snippet?.publishedAt,
      duration: video.contentDetails?.duration,
      standardThumbnailURL: video.snippet?.thumbnails?.standard?.url
    )
  }
}
