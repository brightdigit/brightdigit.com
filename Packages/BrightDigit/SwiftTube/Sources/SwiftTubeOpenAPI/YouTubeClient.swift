import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A lightweight async YouTube client backed by the generated OpenAPI client.
///
/// Exposes only the two operations the importer needs:
/// `playlistItems.list` (paged) and `videos.list` (batched by id).
public struct YouTubeClient: Sendable {
  /// Errors surfaced by ``YouTubeClient``.
  public enum ClientError: Error, Equatable, Sendable {
    /// The server returned a non-200 / undocumented response.
    case invalidResponse
  }

  /// The base URL for the YouTube Data API.
  public static let serverURL = URL(
    string: "https://youtube.googleapis.com"
  )! // swiftlint:disable:this force_unwrapping

  /// The maximum number of ids the `videos.list` endpoint accepts per request.
  private static let batchSize = 50

  private let underlying: Client
  private let apiKey: String

  /// Creates a client.
  ///
  /// - Parameters:
  ///   - apiKey: YouTube Data API key.
  ///   - transport: The transport to use. Defaults to `URLSessionTransport`.
  public init(
    apiKey: String,
    transport: any ClientTransport = URLSessionTransport()
  ) {
    self.apiKey = apiKey
    underlying = Client(
      serverURL: Self.serverURL,
      transport: transport
    )
  }

  /// Creates a client wrapping an already-configured generated client.
  ///
  /// Primarily used by tests to inject a fixture-replaying transport.
  public init(apiKey: String, client: Client) {
    self.apiKey = apiKey
    underlying = client
  }

  /// Fetches video details for every video in a playlist.
  ///
  /// Follows playlist pagination, then fetches video details in batches of
  /// ``batchSize`` (the API's per-request id limit), running the batches
  /// concurrently and reassembling them in batch order so the result is
  /// deterministic.
  public func videos(
    forPlaylistID playlistID: String
  ) async throws -> [YouTubeVideo] {
    let ids = try await playlistVideoIDs(playlistID: playlistID)
    let batches = ids.chunked(by: Self.batchSize)
    return try await videoDetails(forBatches: batches)
  }

  /// All video ids referenced by a playlist, following pagination.
  func playlistVideoIDs(
    playlistID: String
  ) async throws -> [String] {
    var ids: [String] = []
    var pageToken: String?

    repeat {
      let body = try await playlistPage(
        playlistID: playlistID,
        pageToken: pageToken
      )
      ids += (body.items ?? []).compactMap {
        $0.snippet?.resourceId?.videoId
      }
      pageToken = body.nextPageToken
    } while pageToken != nil

    return ids
  }

  /// Field selector for the playlist-items request.
  private static let playlistFields =
    "items/snippet/resourceId/videoId,nextPageToken"

  /// Fetches a single page of playlist items.
  private func playlistPage(
    playlistID: String,
    pageToken: String?
  ) async throws -> Components.Schemas.PlaylistItemListResponse {
    let response = try await underlying.listPlaylistItems(
      query: .init(
        part: "snippet",
        fields: Self.playlistFields,
        key: apiKey,
        playlistId: playlistID,
        maxResults: Self.batchSize,
        pageToken: pageToken
      )
    )
    return try Self.okJSON(response)
  }

  /// Unwraps a `listPlaylistItems` output, throwing on any non-200 response.
  private static func okJSON(
    _ response: Operations.listPlaylistItems.Output
  ) throws -> Components.Schemas.PlaylistItemListResponse {
    guard case let .ok(okResponse) = response,
          case let .json(body) = okResponse.body
    else {
      throw ClientError.invalidResponse
    }
    return body
  }

  /// Unwraps a `listVideos` output, throwing on any non-200 response.
  private static func okJSON(
    _ response: Operations.listVideos.Output
  ) throws -> Components.Schemas.VideoListResponse {
    guard case let .ok(okResponse) = response,
          case let .json(body) = okResponse.body
    else {
      throw ClientError.invalidResponse
    }
    return body
  }

  /// Fetches video details for each batch of ids concurrently, preserving
  /// batch order in the flattened result.
  private func videoDetails(
    forBatches batches: [[String]]
  ) async throws -> [YouTubeVideo] {
    var results = [[YouTubeVideo]?](repeating: nil, count: batches.count)
    try await withThrowingTaskGroup(
      of: (Int, [YouTubeVideo]).self
    ) { group in
      for (index, batch) in batches.enumerated() {
        group.addTask {
          try await (index, videoBatch(ids: batch))
        }
      }
      for try await (index, videos) in group {
        results[index] = videos
      }
    }
    return results.compactMap(\.self).flatMap(\.self)
  }

  /// Field selector for the videos request.
  private static let videoFields =
    "items(id,contentDetails/duration,snippet/title,"
      + "snippet/description,snippet/publishedAt,snippet/thumbnails)"

  /// Fetches video details for a single batch of ids.
  private func videoBatch(ids: [String]) async throws -> [YouTubeVideo] {
    let response = try await underlying.listVideos(
      query: .init(
        part: "contentDetails,snippet",
        fields: Self.videoFields,
        key: apiKey,
        id: ids.joined(separator: ",")
      )
    )
    let body = try Self.okJSON(response)
    return (body.items ?? []).map(YouTubeVideo.init(from:))
  }
}

extension Array {
  /// Splits the array into consecutive subarrays of at most `size` elements,
  /// preserving order. The final chunk may be shorter.
  ///
  /// - Parameter size: Maximum length of each chunk. Must be greater than zero.
  func chunked(by size: Int) -> [[Element]] {
    precondition(size > 0, "chunk size must be greater than zero")
    return stride(from: 0, to: count, by: size).map { start in
      Array(self[start ..< Swift.min(start + size, count)])
    }
  }
}
