/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Protocol adopted by all contexts that define an RSS channel.
public protocol RSSChannelContext {
  /// The channel's item context.
  associatedtype ItemContext: RSSItemContext
}
