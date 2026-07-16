/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Ink
import Plot

/// Component that can be used to parse a Markdown string into HTML
/// that's then rendered as the body of the component.
///
/// You can control what `MarkdownParser` that's used for parsing
/// using the `markdownParser` environment key, or by applying the
/// `markdownParser` modifier to a component.
public struct Markdown: Component {
  /// The Markdown string to render.
  public var string: String

  @EnvironmentValue(.markdownParser) private var parser

  /// The rendered body of the component.
  public var body: Component {
    Node.markdown(string, using: parser)
  }

  /// Initialize an instance of this component with a Markdown string.
  /// - parameter string: The Markdown string to render.
  public init(_ string: String) {
    self.string = string
  }
}
