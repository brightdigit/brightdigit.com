import Foundation
import Contribute

public enum YoutubeError: ContributeError {
  public enum VideoField {
    case snippetTitle
    case id
    case duration
    case description
    case publishedAt
    case thumbnailUrl
  }

  case missingFieldForVideo(Any, VideoField)
  case duplicateTitle(String, forVideos: [Any])
}
