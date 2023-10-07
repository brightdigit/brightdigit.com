import Foundation

public typealias VideoDurations = [String: YouTubeContent.Source]

public extension YouTubeContent {
  struct Source: Equatable {
    public let title: String
    public let description: String
    public let youtubeID: String
    public let duration: TimeInterval
    public let date: Date
    public let imageURL: URL?

    public init(title: String, description: String, youtubeID: String, duration: TimeInterval, date: Date, imageURL: URL?) {
      self.title = title
      self.description = description
      self.youtubeID = youtubeID
      self.duration = duration
      self.date = date
      self.imageURL = imageURL
    }
  }

}
