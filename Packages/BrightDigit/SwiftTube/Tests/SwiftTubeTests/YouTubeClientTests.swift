import Foundation
import OpenAPIRuntime
import XCTest

@testable import SwiftTube

internal final class YouTubeClientTests: XCTestCase {
  private static let playlistID = "PLtest"
  private static let playlistPath = "/youtube/v3/playlistItems"
  private static let videosPath = "/youtube/v3/videos"

  /// Builds a `YouTubeClient` whose generated client uses the supplied mock.
  private func makeClient(_ transport: MockTransport) -> YouTubeClient {
    let generated = Client(
      serverURL: YouTubeClient.serverURL,
      transport: transport
    )
    return YouTubeClient(apiKey: "FAKE_KEY", client: generated)
  }

  /// Two playlist pages (the first carrying `nextPageToken`) are followed, and
  /// a single batched `videos.list` call returns the details in order.
  internal func testFollowsPaginationAndBatchesVideos() async throws {
    let transport = MockTransport(responses: [
      Self.playlistPath: [Fixtures.playlistPage1, Fixtures.playlistPage2],
      Self.videosPath: [Fixtures.videos],
    ])
    let client = makeClient(transport)

    let result = try await client.videos(forPlaylistID: Self.playlistID)

    XCTAssertEqual(result.map(\.id), ["vid1", "vid2", "vid3"])
    XCTAssertEqual(result.map(\.title), ["First", "Second", "Third"])
    XCTAssertEqual(result.map(\.duration), ["PT10M", "PT20M", "PT30M"])
    XCTAssertEqual(result.first?.standardThumbnailURL, "https://img/1.jpg")
    XCTAssertEqual(
      result.first?.publishedAt,
      Date(timeIntervalSince1970: 1_577_836_800)  // 2020-01-01T00:00:00Z
    )

    await assertCallCounts(transport, playlist: 2, videos: 1)
  }

  /// An undocumented (non-200) response surfaces as
  /// `ClientError.invalidResponse`.
  internal func testNon200ResponseThrows() async throws {
    let transport = MockTransport(
      responses: [Self.playlistPath: ["{}"]],
      status: 500
    )
    let client = makeClient(transport)

    do {
      _ = try await client.videos(forPlaylistID: Self.playlistID)
      XCTFail("expected ClientError.invalidResponse")
    } catch let error as YouTubeClient.ClientError {
      XCTAssertEqual(error, .invalidResponse)
    }
  }

  /// Asserts how many times each endpoint was called.
  private func assertCallCounts(
    _ transport: MockTransport,
    playlist: Int,
    videos: Int
  ) async {
    let requestedURLs = await transport.requestedURLs
    let playlistCalls = requestedURLs.filter {
      $0.hasPrefix(Self.playlistPath)
    }
    let videoCalls = requestedURLs.filter {
      $0.hasPrefix(Self.videosPath)
    }
    XCTAssertEqual(playlistCalls.count, playlist)
    XCTAssertEqual(videoCalls.count, videos)
  }
}
