/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Protocol adopted by components that render controls for user input.
public protocol InputComponent: Component {
  /// Whether the component's element should be automatically focused.
  var isAutoFocused: Bool { get set }
}

extension InputComponent {
  /// Tell the browser whether the element should be automatically focused.
  /// - parameter isAutoFocused: Whether the element should be auto-focused.
  /// - Returns: The modified component.
  public func autoFocused(_ isAutoFocused: Bool = true) -> Self {
    var input = self
    input.isAutoFocused = isAutoFocused
    return input
  }
}
