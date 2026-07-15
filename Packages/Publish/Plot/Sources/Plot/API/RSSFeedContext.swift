/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Protocol adopted by all contexts that define an RSS feed.
public protocol RSSFeedContext {
  /// The feed's channel context.
  associatedtype ChannelContext: RSSChannelContext
}
