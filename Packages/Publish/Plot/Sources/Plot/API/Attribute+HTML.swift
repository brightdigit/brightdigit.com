/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Attribute where Context: HTMLContext {
  /// Assign an ID to the current element.
  /// - parameter id: The ID to assign.
  /// - Returns: The created attribute.
  public static func id(_ id: String) -> Attribute {
    Attribute(name: "id", value: id)
  }

  /// Assign a class name to the current element. May also be a list of
  /// space-separated class names.
  /// - parameter className: The class or list of classes to assign.
  /// - Returns: The created attribute.
  public static func `class`(_ className: String) -> Attribute {
    Attribute(name: "class", value: className)
  }

  /// Add a `data-` attribute to the current element.
  /// - Parameters:
  ///   - name: The name of the attribute to add. The name will
  ///     be prefixed with `data-`.
  ///   - value: The attribute's string value.
  /// - Returns: The created attribute.
  public static func data(named name: String, value: String) -> Attribute {
    Attribute(name: "data-\(name)", value: value)
  }

  /// Assign whether operating system level spell checking should be enabled.
  /// - parameter isEnabled: Whether spell checking should be enabled.
  /// - Returns: The created attribute.
  public static func spellcheck(_ isEnabled: Bool) -> Attribute {
    Attribute(name: "spellcheck", value: String(isEnabled))
  }

  /// Specify a title for the element.
  /// - parameter title: The title to assign to the element.
  /// - Returns: The created attribute.
  public static func title(_ title: String) -> Attribute {
    Attribute(name: "title", value: title)
  }

  /// Specify a directionality for the element.
  /// - parameter directionality: The directionality to assign to the element.
  /// - Returns: The created attribute.
  public static func dir(_ directionality: Directionality) -> Attribute {
    Attribute(name: "dir", value: directionality.rawValue)
  }
}

extension Node where Context: HTMLContext {
  /// Assign an ID to the current element.
  /// - parameter id: The ID to assign.
  /// - Returns: The created node.
  public static func id(_ id: String) -> Node {
    .attribute(named: "id", value: id)
  }

  /// Assign a class name to the current element. May also be a list of
  /// space-separated class names.
  /// - parameter className: The class or list of classes to assign.
  /// - Returns: The created node.
  public static func `class`(_ className: String) -> Node {
    .attribute(named: "class", value: className)
  }

  /// Add a `data-` attribute to the current element.
  /// - Parameters:
  ///   - name: The name of the attribute to add. The name will
  ///     be prefixed with `data-`.
  ///   - value: The attribute's string value.
  /// - Returns: The created node.
  public static func data(named name: String, value: String) -> Node {
    .attribute(named: "data-\(name)", value: value)
  }

  /// Assign whether operating system level spell checking should be enabled.
  /// - parameter isEnabled: Whether spell checking should be enabled.
  /// - Returns: The created node.
  public static func spellcheck(_ isEnabled: Bool) -> Node {
    .attribute(named: "spellcheck", value: String(isEnabled))
  }

  /// Specify a title for the element.
  /// - parameter title: The title to assign to the element.
  /// - Returns: The created node.
  public static func title(_ title: String) -> Node {
    .attribute(named: "title", value: title)
  }

  /// Assign whether the element should be hidden.
  /// - parameter isHidden: Whether the element should be hidden or not.
  /// - Returns: The created node.
  public static func hidden(_ isHidden: Bool) -> Node {
    isHidden ? .attribute(named: "hidden") : .empty
  }

  /// Specify a directionality for the element.
  /// - parameter directionality: The directionality to assign to the element.
  /// - Returns: The created node.
  public static func dir(_ directionality: Directionality) -> Node {
    .attribute(named: "dir", value: directionality.rawValue)
  }
}

extension Attribute where Context: HTMLNamableContext {
  /// Assign a name to the element.
  /// - parameter name: The name to assign.
  /// - Returns: The created attribute.
  public static func name(_ name: String) -> Attribute {
    Attribute(name: "name", value: name)
  }
}

extension Node where Context: HTMLNamableContext {
  /// Assign a name to the element.
  /// - parameter name: The name to assign.
  /// - Returns: The created node.
  public static func name(_ name: String) -> Node {
    .attribute(named: "name", value: name)
  }
}

extension Attribute where Context == HTML.MetaContext {
  /// Assign a property to the element.
  /// - parameter property: The property to assign.
  /// - Returns: The created attribute.
  public static func property(_ property: String) -> Attribute {
    Attribute(name: "property", value: property)
  }
}

extension Attribute where Context: HTMLTypeContext {
  /// Assign a type string to this element.
  /// - parameter type: The name of the type to assign.
  /// - Returns: The created attribute.
  public static func type(_ type: String) -> Attribute {
    Attribute(name: "type", value: type)
  }
}

extension Attribute where Context: HTMLValueContext {
  /// Assign a string value to the element.
  /// - parameter value: The value to assign.
  /// - Returns: The created attribute.
  public static func value(_ value: String) -> Attribute {
    Attribute(name: "value", value: value)
  }
}

extension Node where Context: HTMLValueContext {
  /// Assign a string value to the element.
  /// - parameter value: The value to assign.
  /// - Returns: The created node.
  public static func value(_ value: String) -> Node {
    .attribute(named: "value", value: value)
  }
}

// MARK: - Document

extension Node where Context == HTML.DocumentContext {
  /// Specify the language of the HTML document's content.
  /// - parameter language: The language to specify.
  /// - Returns: The created node.
  public static func lang(_ language: Language) -> Node {
    .attribute(named: "lang", value: language.rawValue)
  }
}
