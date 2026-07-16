/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot

extension Theme {
  /// The default "Foundation" theme that Publish ships with, a very
  /// basic theme mostly implemented for demonstration purposes.
  public static var foundation: Self {
    Theme(
      htmlFactory: FoundationHTMLFactory(),
      resourcePaths: ["Resources/FoundationTheme/styles.css"]
    )
  }
}
