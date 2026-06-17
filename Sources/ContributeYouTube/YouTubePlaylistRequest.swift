// swift-format-ignore-file
// swiftlint:disable all
import Foundation

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public struct YouTubePlaylistRequest {
  let apiKey: String
  let playlistID: String

  public init(apiKey: String, playlistID: String) {
    self.apiKey = apiKey
    self.playlistID = playlistID
  }
}
