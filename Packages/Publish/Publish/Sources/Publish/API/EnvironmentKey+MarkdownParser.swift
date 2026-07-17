/**
*  Publish
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import Ink
import Plot

extension EnvironmentKey where Value == MarkdownParser {
  /// Environment key that can be used to pass what `MarkdownParser` that
  /// should be used when rendering `Markdown` components.
  public static var markdownParser: Self { .init(defaultValue: .init()) }
}
