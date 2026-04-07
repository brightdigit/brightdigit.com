import Foundation

/// A protocol that represents a source of HTML content.
public protocol HTMLSource {
  /// The HTML content.
  var html: String { get }
}
