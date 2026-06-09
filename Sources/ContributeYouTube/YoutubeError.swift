import Foundation
import Contribute

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
