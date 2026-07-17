/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Component used to render input controls using the `<input>` element.
public struct Input: InputComponent {
  /// The type of input to render. See `HTMLInputType` for more info.
  public var type: HTMLInputType
  /// The rendered element's name. Maps to the `name` attribute.
  public var name: String?
  /// The rendered element's value. Maps to the `value` attribute.
  public var value: String?
  /// Whether the input element should be considered required.
  public var isRequired: Bool
  /// Any placeholder to render within the input element.
  public var placeholder: String?
  /// Whether the input should be focused automatically.
  public var isAutoFocused = false

  @EnvironmentValue(.isAutoCompleteEnabled) private var isAutoCompleteEnabled

  /// The content and behavior of this component.
  public var body: Component {
    Node.input(
      .type(type),
      .unwrap(name, Attribute.name),
      .unwrap(value, Attribute.value),
      .required(isRequired),
      .unwrap(placeholder, Attribute.placeholder),
      .autofocus(isAutoFocused),
      .unwrap(isAutoCompleteEnabled, Attribute.autocomplete)
    )
  }

  /// Create a new input component instance.
  /// - parameters:
  ///   - type: The type of input to render. See `HTMLInputType` for more info.
  ///   - name: The rendered element's name. Maps to the `name` attribute.
  ///   - value: The rendered element's value. Maps to the `value` attribute.
  ///   - isRequired: Whether the input element should be considered required.
  ///   - placeholder: Any placeholder to render within the input element.
  public init(
    type: HTMLInputType,
    name: String? = nil,
    value: String? = nil,
    isRequired: Bool = false,
    placeholder: String? = nil
  ) {
    self.type = type
    self.name = name
    self.value = value
    self.isRequired = isRequired
    self.placeholder = placeholder
  }
}
