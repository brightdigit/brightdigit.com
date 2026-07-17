/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import Foundation

extension Optional: Renderable, Component where Wrapped: Component {
  /// The content and behavior of this component.
  public var body: Component {
    self?.body ?? EmptyComponent()
  }
}
