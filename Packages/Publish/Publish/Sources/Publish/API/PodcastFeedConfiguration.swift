/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Plot

/// Configuration type used to customize how a podcast feed is generated when
/// using the `generatePodcastFeed` step. To use a default implementation,
/// use `PodcastFeedConfiguration.default`.
public struct PodcastFeedConfiguration<Site: Website>: FeedConfiguration, Sendable {
  /// The path that the feed should be generated at.
  public var targetPath: Path
  /// The feed's TTL time interval.
  public var ttlInterval: TimeInterval
  /// The maximum number of items that the feed should contain.
  public var maximumItemCount: Int
  /// How the feed should be indented.
  public var indentation: Indentation.Kind?
  /// The type of the podcast. See `PodcastType`.
  public var type: PodcastType
  /// A URL that points to the podcast's main image.
  public var imageURL: URL
  /// The copyright text to add to the podcast feed.
  public var copyrightText: String
  /// The podcast's author. See `PodcastAuthor`.
  public var author: PodcastAuthor
  /// A longer description of the podcast.
  public var description: String
  /// A shorter description, or subtitle, for the podcast.
  public var subtitle: String
  /// Whether the podcast contains explicit content.
  public var isExplicit: Bool
  /// The podcast's main top-level category.
  public var category: String
  /// The podcast's subcategory.
  public var subcategory: String?
  /// Any new feed URL to instruct Apple Podcasts to use going forward.
  public var newFeedURL: URL?

  /// Initialize a new configuration instance.
  /// - Parameters:
  ///   - targetPath: The path that the feed should be generated at.
  ///   - ttlInterval: The feed's TTL time interval.
  ///   - maximumItemCount: The maximum number of items that the
  ///       feed should contain.
  ///   - type: The type of the podcast.
  ///   - imageURL: A URL that points to the podcast's main image.
  ///   - copyrightText: The copyright text to add to the podcast feed.
  ///   - author: The podcast's author.
  ///   - description: A longer description of the podcast.
  ///   - subtitle: A shorter description, or subtitle, for the podcast.
  ///   - isExplicit: Whether the podcast contains explicit content.
  ///   - category: The podcast's main top-level category.
  ///   - subcategory: The podcast's subcategory.
  ///   - newFeedURL: Any new feed URL for the podcast.
  ///   - indentation: How the feed should be indented.
  public init(
    targetPath: Path,
    ttlInterval: TimeInterval = 250,
    maximumItemCount: Int = .max,
    type: PodcastType = .episodic,
    imageURL: URL,
    copyrightText: String,
    author: PodcastAuthor,
    description: String,
    subtitle: String,
    isExplicit: Bool = false,
    category: String,
    subcategory: String? = nil,
    newFeedURL: URL? = nil,
    indentation: Indentation.Kind? = nil
  ) {
    self.targetPath = targetPath
    self.ttlInterval = ttlInterval
    self.maximumItemCount = maximumItemCount
    self.indentation = indentation
    self.type = type
    self.imageURL = imageURL
    self.copyrightText = copyrightText
    self.author = author
    self.description = description
    self.subtitle = subtitle
    self.category = category
    self.subcategory = subcategory
    self.isExplicit = isExplicit
    self.newFeedURL = newFeedURL
  }
}
