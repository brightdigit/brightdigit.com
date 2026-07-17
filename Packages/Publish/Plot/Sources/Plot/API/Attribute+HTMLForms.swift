/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Node where Context == HTML.FormContext {
  /// Assign a URL that this form should be sent to when submitted.
  /// - parameter url: The action URL that the form should be sent to.
  /// - Returns: The created node.
  public static func action(_ url: URLRepresentable) -> Node {
    .attribute(named: "action", value: url.string)
  }

  /// Assign a specific content type to the form.
  /// - Parameter type: The content type to assign.
  /// - Returns: The created node.
  public static func enctype(_ type: HTMLFormContentType) -> Node {
    .attribute(named: "enctype", value: type.rawValue)
  }

  /// Assign a specific HTTP request method that the form should
  /// be submitted using.
  /// - Parameter method: The HTTP request method to use.
  /// - Returns: The created node.
  public static func method(_ method: HTMLFormMethod) -> Node {
    .attribute(named: "method", value: method.rawValue)
  }

  /// Add the `novalidate` attribute to the form, which
  /// disables any native browser validation on the form.
  /// - parameter isOn: Whether validation should be disabled.
  /// - Returns: The created node.
  public static func novalidate(_ isOn: Bool = true) -> Node {
    isOn ? .attribute(named: "novalidate") : .empty
  }
}

extension Node where Context == HTML.LabelContext {
  /// Assign which input control that this label is for.
  /// - parameter target: The target input control's name.
  /// - Returns: The created node.
  public static func `for`(_ target: String) -> Node {
    .attribute(named: "for", value: target)
  }
}

extension Attribute where Context == HTML.InputContext {
  /// Assign an input type to the element.
  /// - parameter type: The input type to assign.
  /// - Returns: The created attribute.
  public static func type(_ type: HTMLInputType) -> Attribute {
    Attribute(name: "type", value: type.rawValue)
  }

  /// Assign a placeholder to the input field.
  /// - parameter placeholder: The placeholder to assign.
  /// - Returns: The created attribute.
  public static func placeholder(_ placeholder: String) -> Attribute {
    Attribute(name: "placeholder", value: placeholder)
  }

  /// Assign whether the element should have autocomplete turned on or off.
  /// - parameter isOn: Whether autocomplete should be turned on.
  /// - Returns: The created attribute.
  public static func autocomplete(_ isOn: Bool) -> Attribute {
    Attribute(name: "autocomplete", value: isOn ? "on" : "off")
  }

  /// Assign whether the element is required before submitting the form.
  /// - parameter isRequired: Whether the element is required.
  /// - Returns: The created attribute.
  public static func required(_ isRequired: Bool) -> Attribute {
    isRequired ? Attribute(name: "required", value: nil, ignoreIfValueIsEmpty: false) : .empty
  }

  /// Assign whether the element should be autofocused when the page loads.
  /// - parameter isOn: Whether autofocus should be turned on.
  /// - Returns: The created attribute.
  public static func autofocus(_ isOn: Bool) -> Attribute {
    isOn ? Attribute(name: "autofocus", value: nil, ignoreIfValueIsEmpty: false) : .empty
  }

  /// Assign whether the element should be read-only.
  /// - parameter isReadonly: Whether the input is read-only.
  /// - Returns: The created attribute.
  public static func readonly(_ isReadonly: Bool) -> Attribute {
    isReadonly ? Attribute(name: "readonly", value: nil, ignoreIfValueIsEmpty: false) : .empty
  }

  /// Assign whether the element should be disabled.
  /// - parameter isDisabled: Whether the input is disabled.
  /// - Returns: The created attribute.
  public static func disabled(_ isDisabled: Bool) -> Attribute {
    isDisabled ? Attribute(name: "disabled", value: nil, ignoreIfValueIsEmpty: false) : .empty
  }

  /// Assign whether the element should allow the selection of multiple values.
  /// - parameter isEnabled: Whether multiple values are allowed.
  /// - Returns: The created attribute.
  public static func multiple(_ isEnabled: Bool) -> Attribute {
    isEnabled ? Attribute(name: "multiple", value: nil, ignoreIfValueIsEmpty: false) : .empty
  }

  /// Assign whether a checkbox or radio input element has an active state.
  /// - parameter isChecked: Whether the element has an active state.
  /// - Returns: The created attribute.
  public static func checked(_ isChecked: Bool) -> Attribute {
    isChecked ? Attribute(name: "checked", value: nil, ignoreIfValueIsEmpty: false) : .empty
  }
}

extension Node where Context == HTML.ButtonContext {
  /// Assign a button type to the element.
  /// - parameter type: The button type to assign.
  /// - Returns: The created node.
  public static func type(_ type: HTMLButtonType) -> Node {
    .attribute(named: "type", value: type.rawValue)
  }
}

extension Node where Context == HTML.TextAreaContext {
  /// Specify the number of columns that the text area should contain.
  /// - parameter columns: The number of columns to specify.
  /// - Returns: The created node.
  public static func cols(_ columns: Int) -> Node {
    .attribute(named: "cols", value: String(columns))
  }

  /// Specify the number of text rows that should be visible within the text area.
  /// - parameter rows: The number of rows to specify.
  /// - Returns: The created node.
  public static func rows(_ rows: Int) -> Node {
    .attribute(named: "rows", value: String(rows))
  }

  /// Assign a placeholder to the text area.
  /// - parameter placeholder: The placeholder to assign.
  /// - Returns: The created node.
  public static func placeholder(_ placeholder: String) -> Node {
    .attribute(named: "placeholder", value: placeholder)
  }

  /// Assign whether the element is required before submitting the form.
  /// - parameter isRequired: Whether the element is required.
  /// - Returns: The created node.
  public static func required(_ isRequired: Bool) -> Node {
    isRequired ? .attribute(named: "required") : .empty
  }

  /// Assign whether the element should be autofocused when the page loads.
  /// - parameter isOn: Whether autofocus should be turned on.
  /// - Returns: The created node.
  public static func autofocus(_ isOn: Bool) -> Node {
    isOn ? .attribute(named: "autofocus") : .empty
  }

  /// Assign whether the element should be read-only.
  /// - parameter isReadonly: Whether the input is read-only.
  /// - Returns: The created node.
  public static func readonly(_ isReadonly: Bool) -> Node {
    isReadonly ? .attribute(named: "readonly") : .empty
  }

  /// Assign whether the element should be disabled.
  /// - parameter isDisabled: Whether the input is disabled.
  /// - Returns: The created node.
  public static func disabled(_ isDisabled: Bool) -> Node {
    isDisabled ? .attribute(named: "disabled") : .empty
  }
}

extension Attribute where Context == HTML.OptionContext {
  /// Specify whether the option should be initially selected.
  /// - parameter isSelected: Whether the option should be selected.
  /// - Returns: The created attribute.
  public static func isSelected(_ isSelected: Bool) -> Attribute {
    guard isSelected else {
      return .empty
    }

    return Attribute(
      name: "selected",
      value: nil,
      ignoreIfValueIsEmpty: false
    )
  }

  /// Assign a label to the given option.
  /// - parameter label: The user displayed value of the option
  /// - Returns: The created attribute.
  public static func label(_ label: String) -> Attribute {
    Attribute(name: "label", value: label, ignoreIfValueIsEmpty: false)
  }
}
