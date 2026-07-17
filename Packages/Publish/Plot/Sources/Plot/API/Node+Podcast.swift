/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Node where Context == PodcastFeed.ChannelContext {
  /// Instruct Apple Podcasts that the podcast's feed has moved to a new URL.
  /// - parameter url: The feed's new URL.
  /// - Returns: The created node.
  public static func newFeedURL(_ url: URLRepresentable) -> Node {
    .element(named: "itunes:new-feed-url", text: url.string)
  }

  /// Attach a copyright notice to the feed.
  /// - parameter text: The copyright text to attach.
  /// - Returns: The created node.
  public static func copyright(_ text: String) -> Node {
    .element(named: "copyright", text: text)
  }

  /// Define the podcast's owner.
  /// - parameter nodes: The element's child nodes.
  /// - Returns: The created node.
  public static func owner(_ nodes: Node<PodcastFeed.OwnerContext>...) -> Node {
    .element(named: "itunes:owner", nodes: nodes)
  }

  /// Declare the podcast's type.
  /// - parameter type: The type to declare. See `PodcastType` for more info.
  /// - Returns: The created node.
  public static func type(_ type: PodcastType) -> Node {
    .element(named: "itunes:type", text: type.rawValue)
  }
}

// MARK: - Any content context

extension Node where Context: PodcastContentContext {
  /// Declare who is the author of the content.
  /// - parameter name: The name of the author.
  /// - Returns: The created node.
  public static func author(_ name: String) -> Node {
    .element(named: "itunes:author", text: name)
  }

  /// Define a subtitle for the content.
  /// - parameter text: The content's subtitle.
  /// - Returns: The created node.
  public static func subtitle(_ text: String) -> Node {
    .element(named: "itunes:subtitle", text: text)
  }

  /// Define a summary text for the content.
  /// - parameter text: The content's summary text.
  /// - Returns: The created node.
  public static func summary(_ text: String) -> Node {
    .element(named: "itunes:summary", text: text)
  }

  /// Declare whether the content is explicit.
  ///
  /// See Apple Podcast's guidelines as to what kind of content is
  /// considered explicit, and should be marked with this flag.
  ///
  /// - parameter isExplicit: Whether the content is explicit.
  /// - Returns: The created node.
  public static func explicit(_ isExplicit: Bool) -> Node {
    .element(
      named: "itunes:explicit",
      text: isExplicit ? "yes" : "no"
    )
  }

  /// Associate an image with the content.
  /// - parameter url: The URL of the content's image.
  /// - Returns: The created node.
  public static func image(_ url: URLRepresentable) -> Node {
    .selfClosedElement(
      named: "itunes:image",
      attributes: [.any(name: "href", value: url.string)]
    )
  }
}

// MARK: - Owner

extension Node where Context == PodcastFeed.OwnerContext {
  /// Define the owner's name.
  /// - parameter name: The owner's name.
  /// - Returns: The created node.
  public static func name(_ name: String) -> Node {
    .element(named: "itunes:name", text: name)
  }

  /// Define the owner's email address.
  /// - parameter email: The owner's email address.
  /// - Returns: The created node.
  public static func email(_ email: String) -> Node {
    .element(named: "itunes:email", text: email)
  }
}

// MARK: - Categories

extension Node where Context: PodcastCategoryContext {
  /// Define the category that the podcast belongs to.
  /// - Parameters:
  ///   - name: The name of the category.
  ///   - subcategory: Any optional, more specific subcategory.
  /// - Returns: The created node.
  public static func category(
    _ name: String, _ subcategory: Node<PodcastFeed.CategoryContext> = .empty
  ) -> Node {
    .element(
      Element(
        name: "itunes:category",
        closingMode: .selfClosing,
        nodes: [
          .attribute(named: "text", value: name),
          subcategory,
        ]
      )
    )
  }
}
