/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Component that can be used to render a user-editable text area
/// using the `<textarea>` element.
public struct TextArea: InputComponent {
  /// The initial text that the text area should contain.
  public var text: String
  /// The name of the component's element. Maps to the `name` attribute.
  public var name: String?
  /// The vertical size of the text area, measured in rows.
  /// Maps to the `rows` attribute.
  public var numberOfRows: Int?
  /// The horizontal size of the text area, measured in columns.
  /// Maps to the `cols` attribute.
  public var numberOfColumns: Int?
  /// Whether the text area should be required to fill in.
  public var isRequired: Bool
  /// Whether the browser should auto-focus the text field.
  public var isAutoFocused = false

  /// The content and behavior of this component.
  public var body: Component {
    Node.textarea(
      .text(text),
      .unwrap(name, Node.name),
      .unwrap(numberOfRows, Node.rows),
      .unwrap(numberOfColumns, Node.cols),
      .required(isRequired),
      .unwrap(isAutoFocused, Node.autofocus)
    )
  }

  /// Create a new text area.
  /// - parameters:
  ///   - text: The initial text that the text area should contain.
  ///   - name: The name of the component's element. Maps to the `name` attribute.
  ///   - numberOfRows: The vertical size of the text area, measured in rows.
  ///     Maps to the `rows` attribute.
  ///   - numberOfColumns: The horizontal size of the text area, measured in columns.
  ///     Maps to the `cols` attribute.
  ///   - isRequired: Whether the text area should be required to fill in.
  public init(
    text: String = "",
    name: String? = nil,
    numberOfRows: Int? = nil,
    numberOfColumns: Int? = nil,
    isRequired: Bool = false
  ) {
    self.text = text
    self.name = name
    self.numberOfRows = numberOfRows
    self.numberOfColumns = numberOfColumns
    self.isRequired = isRequired
  }
}
