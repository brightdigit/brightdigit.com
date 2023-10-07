import Foundation

public typealias BrightDigitPodcastMedia = BrightDigitPodcast.Media

public extension BrightDigitPodcast {
  struct Media {
    public let youtubeID: String
    public let youtubeDuration: TimeInterval
    public let podcastID: String
    public let podcastDuration: TimeInterval
    public let audioURL: URL
    public let imageURL: URL

    public init(youtubeID: String, videoDuration: TimeInterval, podcastID: String, audioDuration: TimeInterval, audioURL: URL, imageURL: URL) {
      self.youtubeID = youtubeID
      self.youtubeDuration = videoDuration
      self.podcastID = podcastID
      self.podcastDuration = audioDuration
      self.audioURL = audioURL
      self.imageURL = imageURL
    }
  }
}
