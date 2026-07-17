/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Type used to describe metadata for a podcast episode.
public struct PodcastEpisodeMetadata: Hashable, Sendable {
  /// The episode's number.
  public var episodeNumber: Int?
  /// The number of the episode's season.
  public var seasonNumber: Int?
  /// Whether the episode contains explicit content.
  public var isExplicit: Bool

  /// Initialize a new instance of this type.
  /// - Parameters:
  ///   - episodeNumber: The episode's number.
  ///   - seasonNumber: The number of the episode's season.
  ///   - isExplicit: Whether the episode contains explicit content.
  public init(
    episodeNumber: Int? = nil,
    seasonNumber: Int? = nil,
    isExplicit: Bool = false
  ) {
    self.episodeNumber = episodeNumber
    self.seasonNumber = seasonNumber
    self.isExplicit = isExplicit
  }
}

extension PodcastEpisodeMetadata: Decodable {
  /// Initialize an instance by decoding from the given decoder.
  /// - parameter decoder: The decoder to read data from.
  /// - Throws: An error if decoding fails.
  public init(from decoder: Decoder) throws {
    episodeNumber = try decoder.decodeIfPresent("episode")
    seasonNumber = try decoder.decodeIfPresent("season")
    isExplicit = try decoder.decodeIfPresent("explicit") ?? false
  }
}
