// swift-format-ignore-file
// swiftlint:disable all
import Foundation
import Contribute

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public enum YoutubeError: ContributeError {
  public enum VideoField: Sendable {
    case snippetTitle
    case id
    case duration
    case description
    case publishedAt
    case thumbnailUrl
  }

  case missingFieldForVideo(String, VideoField)
  case duplicateTitle(String, forVideos: [String])
}
