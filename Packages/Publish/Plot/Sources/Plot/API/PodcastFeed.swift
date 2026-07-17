/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// A representation of a podcast feed. Create an instance of this
/// type to build a feed using Plot's type-safe DSL, and then call
/// the `render()` method to turn it into an RSS string.
public struct PodcastFeed: RSSBasedDocumentFormat {
  private let document: Document<PodcastFeed>

  /// Create a podcast feed with a collection of nodes that make
  /// up the items (episodes) in the feed. Each item can be created
  /// using the `.item()` API.
  /// - parameter nodes: The nodes that make up the podcast's
  ///   episodes. Will be placed within a `<channel>` element.
  public init(_ nodes: Node<ChannelContext>...) {
    document = .feed(
      .namespace("itunes", "http://www.itunes.com/dtds/podcast-1.0.dtd"),
      .namespace("media", "http://www.rssboard.org/media-rss"),
      .channel(.group(nodes))
    )
  }
}

extension PodcastFeed: NodeConvertible {
  /// The node representation of this document.
  public var node: Node<Self> { document.node }
}

extension PodcastFeed {
  /// The root context of a podcast feed. Plot automatically creates
  /// all required elements within this context for you.
  public enum RootContext: RSSRootContext {}
  /// The context within the top level of a podcast feed, within the
  /// `<rss>` element. Plot automatically creates all required elements
  /// within this context for you.
  public enum FeedContext: RSSFeedContext {
    /// The context type used within a podcast feed's channel.
    public typealias ChannelContext = PodcastFeed.ChannelContext
  }
  /// The context within a podcast's `<channel>` element, in which
  /// episodes can be defined.
  public enum ChannelContext: RSSChannelContext, PodcastContentContext, PodcastCategoryContext {
    /// The context type used within a podcast feed's item.
    public typealias ItemContext = PodcastFeed.ItemContext
  }
  /// The context within a podcast's `<itunes:category>` element.
  public enum CategoryContext: PodcastCategoryContext {}
  /// The context within a podcast episode's `<enclosure>` element.
  public enum EnclosureContext {}
  /// The context within a podcast episode's `<item>` element.
  public enum ItemContext: PodcastContentContext, RSSItemContext {}
  /// The context within a podcast episode's `<media_content>` element.
  public enum MediaContext {}
  /// The context within a podcast's `<itunes:owner>` element.
  public enum OwnerContext: PodcastNameableContext {}
}
