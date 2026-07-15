/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Protocol used to define a document format. Plot ships with a number
/// of different implementations of this protocol, such as `HTML`, `RSS`,
/// and `XML`, but you can also create your own types by conforming to it.
///
/// Built-in document types are created simply by initializing them, while
/// custom ones can be created using the `Document.custom` APIs.
public protocol DocumentFormat {
  /// The root context of the document, which all top-level elements are
  /// bound to. Each document format is free to define any number of contexts
  /// in order to limit where an element or attribute may be placed.
  associatedtype RootContext
}
