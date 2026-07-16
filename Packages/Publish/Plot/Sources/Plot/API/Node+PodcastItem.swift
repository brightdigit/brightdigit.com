/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Node where Context == PodcastFeed.ItemContext {
  /// Define the episode's title.
  /// - parameter title: The title to define.
  /// - Returns: The created node.
  public static func title(_ title: String) -> Node {
    .group(
      .element(named: "title", text: title),
      .element(named: "itunes:title", text: title)
    )
  }

  /// Define the duration of the episode as a string.
  ///
  /// Consider using the more type-safe `hours:minutes:seconds:` variant
  /// if you're defining a duration in code.
  ///
  /// - parameter string: A string that describes the episode's duration.
  ///   Should be specified in the HH:mm:ss format.
  /// - Returns: The created node.
  public static func duration(_ string: String) -> Node {
    .element(named: "itunes:duration", text: string)
  }

  /// Define the duration of the episode.
  /// - Parameters:
  ///   - hours: The number of hours.
  ///   - minutes: The number of minutes.
  ///   - seconds: The number of seconds.
  /// - Returns: The created node.
  public static func duration(hours: Int, minutes: Int, seconds: Int) -> Node {
    func wrap(_ number: Int) -> String {
      number < 10 ? "0\(number)" : String(number)
    }

    return .duration("\(wrap(hours)):\(wrap(minutes)):\(wrap(seconds))")
  }

  /// Define which season that the episode belongs to.
  /// - parameter number: The number of the episode's season.
  /// - Returns: The created node.
  public static func seasonNumber(_ number: Int) -> Node {
    .element(named: "itunes:season", text: String(number))
  }

  /// Define the episode's number.
  /// - parameter number: The episode number.
  /// - Returns: The created node.
  public static func episodeNumber(_ number: Int) -> Node {
    .element(named: "itunes:episode", text: String(number))
  }

  /// Define the episode's type.
  /// - parameter type: The type of the episode. See `PodcastEpisodeType`.
  /// - Returns: The created node.
  public static func episodeType(_ type: PodcastEpisodeType) -> Node {
    .element(named: "itunes:episodeType", text: type.rawValue)
  }

  /// Define an enclosure for the episode's media files.
  /// - parameter attributes: The element's attributes.
  /// - Returns: The created node.
  public static func enclosure(_ attributes: Attribute<PodcastFeed.EnclosureContext>...) -> Node {
    .selfClosedElement(named: "enclosure", attributes: attributes)
  }

  /// Define the episode's media content metadata.
  /// - parameter nodes: The element's child elements and attributes.
  /// - Returns: The created node.
  public static func mediaContent(_ nodes: Node<PodcastFeed.MediaContext>...) -> Node {
    .element(named: "media:content", nodes: nodes)
  }
}

// MARK: - Media

extension Node where Context == PodcastFeed.MediaContext {
  /// Assign an URL from which the media's file can be downloaded.
  /// - parameter url: The URL to assign.
  /// - Returns: The created node.
  public static func url(_ url: URLRepresentable) -> Node {
    .attribute(named: "url", value: url.string)
  }

  /// Assign a length to the media item, in terms of its file size.
  /// - parameter byteCount: The file's size in bytes.
  /// - Returns: The created node.
  public static func length(_ byteCount: Int) -> Node {
    .attribute(named: "length", value: String(byteCount))
  }

  /// Assign a MIME type to the media item.
  /// - parameter mimeType: The MIME type to assign.
  /// - Returns: The created node.
  public static func type(_ mimeType: String) -> Node {
    .attribute(named: "type", value: mimeType)
  }

  /// Define whether the media item is the default one for this episode.
  /// - parameter isDefault: Whether this is the default media item.
  /// - Returns: The created node.
  public static func isDefault(_ isDefault: Bool) -> Node {
    .attribute(named: "isDefault", value: String(isDefault))
  }

  /// Define the type of this media item.
  /// - parameter type: The type of the item. See `PodcastMediaType`.
  /// - Returns: The created node.
  public static func medium(_ type: PodcastMediaType) -> Node {
    .attribute(named: "medium", value: type.rawValue)
  }

  /// Define the media item's title (usually the episode's title).
  /// - Parameter title: The title to define.
  /// - Returns: The created node.
  public static func title(_ title: String) -> Node {
    .element(
      named: "media:title",
      nodes: [
        .attribute(named: "type", value: "plain"),
        Node.text(title),
      ]
    )
  }
}
