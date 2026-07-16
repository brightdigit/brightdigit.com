/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Convenience type that can be used to create an `Input` component
/// for submitting an HTML form.
public struct SubmitButton: Component {
  /// The name of the component's element. Maps to the `name` attribute.
  public var name: String?
  /// The title of the button. Maps to the `value` attribute.
  public var title: String

  /// The content and behavior of this component.
  public var body: Component {
    Input(type: .submit, name: name, value: title)
  }

  /// Create a new submit button.
  /// - parameters:
  ///   - name: The name of the component's element. Maps to the `name` attribute.
  ///   - title: The title of the button. Maps to the `value` attribute.
  public init(name: String? = nil, title: String) {
    self.name = name
    self.title = title
  }

  /// Create a new submit button without a name
  /// - parameter title: The title of the button. Maps to the `value` attribute.
  public init(_ title: String) {
    self.init(title: title)
  }
}
