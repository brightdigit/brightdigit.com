/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Context shared among all HTML elements that can act as containers
/// for a list of `<source>` elements.
public protocol HTMLSourceListContext: HTMLContext {
  /// The context within the element's `<source>` child elements.
  associatedtype SourceContext
}
