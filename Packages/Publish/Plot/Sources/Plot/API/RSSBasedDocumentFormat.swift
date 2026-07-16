/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Protocol adopted by all document formats that are based on RSS.
public protocol RSSBasedDocumentFormat: DocumentFormat where RootContext: RSSRootContext {
  /// The context of the document's feed
  associatedtype FeedContext: RSSFeedContext
}
