/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Convenience type that can be used to render a text-based `Input` component.
public struct TextField: InputComponent {
  /// The name of the text field's element. Maps to the `name` attribute.
  public var name: String?
  /// The text field's initial text value. Maps to the `value` attribute.
  public var text: String
  /// Any placeholder to render when the text field is empty.
  public var placeholder: String?
  /// Whether the text field should be required to fill in.
  public var isRequired: Bool
  /// Whether the browser should auto-focus the text field.
  public var isAutoFocused = false

  /// The content and behavior of this component.
  public var body: Component {
    Input(
      type: .text,
      name: name,
      value: text,
      isRequired: isRequired,
      placeholder: placeholder
    )
    .autoFocused(isAutoFocused)
  }

  /// Create a new text field.
  /// - parameters:
  ///   - name: The name of the text field's element. Maps to the `name` attribute.
  ///   - text: The text field's initial text value. Maps to the `value` attribute.
  ///   - placeholder: Any placeholder to render when the text field is empty.
  ///   - isRequired: Whether the text field should be required to fill in.
  public init(
    name: String? = nil,
    text: String = "",
    placeholder: String? = nil,
    isRequired: Bool = false
  ) {
    self.name = name
    self.text = text
    self.placeholder = placeholder
    self.isRequired = isRequired
  }
}
