// swift-format-ignore-file
// swiftlint:disable all
import Foundation

public struct YouTubePlaylistRequest {
  let apiKey: String
  let playlistID: String

  public init(apiKey: String, playlistID: String) {
    self.apiKey = apiKey
    self.playlistID = playlistID
  }
}
