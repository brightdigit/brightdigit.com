/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Node where Context == PodcastFeed.ItemContext {
  /// Add an audio enclosure to the item, which defines where a podcast player
  /// can fetch the audio associated with the episode that the item represents.
  /// - Parameters:
  ///   - url: The URL of the audio file.
  ///   - byteSize: The size of the audio file in bytes.
  ///   - type: The MIME type of the audio (default: "audio/mpeg", or MP3).
  ///   - title: The title of the episode.
  /// - Returns: The created node.
  public static func audio(
    url: URLRepresentable,
    byteSize: Int,
    type: String = "audio/mpeg",
    title: String
  ) -> Node {
    .group(
      .enclosure(
        .url(url),
        .length(byteSize),
        .type(type)
      ),
      .mediaContent(
        .url(url),
        .length(byteSize),
        .type(type),
        .isDefault(true),
        .medium(.audio),
        .title(title)
      )
    )
  }
}
