/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot

internal struct Wrapper: ComponentContainer {
  @ComponentBuilder internal var content: ContentProvider

  internal var body: Component {
    Div(content: content).class("wrapper")
  }
}
