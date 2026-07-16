/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Attribute where Context: HTMLDimensionContext {
  /// Assign a given width to the element.
  /// - parameter width: The width to assign.
  /// - Returns: The created attribute.
  public static func width(_ width: Int) -> Attribute {
    Attribute(name: "width", value: String(width))
  }

  /// Assign a given height to the element
  /// - parameter height: The height to assign.
  /// - Returns: The created attribute.
  public static func height(_ height: Int) -> Attribute {
    Attribute(name: "height", value: String(height))
  }
}

extension Node where Context: HTMLStylableContext {
  /// Assign inline CSS to the element, using its `style` attribute.
  /// - parameter css: The CSS string to assign.
  /// - Returns: The created node.
  public static func style(_ css: String) -> Node {
    .attribute(named: "style", value: css)
  }
}

// MARK: - Metadata

extension Attribute where Context == HTML.MetaContext {
  /// Assign an encoding to the element, using its `charset` attribute.
  /// - parameter encoding: The encoding to assign. See `DocumentEncoding`.
  /// - Returns: The created attribute.
  public static func charset(_ encoding: DocumentEncoding) -> Attribute {
    Attribute(name: "charset", value: encoding.rawValue)
  }

  /// Assign a content string to the element.
  /// - parameter content: The content value to assign.
  /// - Returns: The created attribute.
  public static func content(_ content: String) -> Attribute {
    Attribute(name: "content", value: content)
  }
}

// MARK: - iFrames

extension Attribute where Context == HTML.IFrameContext {
  /// Assign whether the iframe should display a border or not.
  /// - parameter isOn: Whether a border should be displayed.
  /// - Returns: The created attribute.
  public static func frameborder(_ isOn: Bool) -> Attribute {
    Attribute(name: "frameborder", value: isOn ? "1" : "0")
  }

  /// Assign what sort of features that the iframe should be allowed to access.
  /// - parameter features: A list of feature names to allow.
  /// - Returns: The created attribute.
  public static func allow(_ features: String...) -> Attribute {
    Attribute(name: "allow", value: features.joined(separator: "; "))
  }

  /// Assign whether to grant the iframe full screen capabilities.
  /// - parameter allow: Whether the iframe should be allowed to go full screen.
  /// - Returns: The created attribute.
  public static func allowfullscreen(_ allow: Bool) -> Attribute {
    allow ? Attribute(name: "allowfullscreen", value: nil, ignoreIfValueIsEmpty: false) : .empty
  }
}

// MARK: - Images

extension Attribute where Context == HTML.ImageContext {
  /// Assign an alternative text to the image. This is important both for
  /// accessibility, and in case the referenced image can't be rendered.
  /// - parameter text: The alternative text to use.
  /// - Returns: The created attribute.
  public static func alt(_ text: String) -> Attribute {
    Attribute(name: "alt", value: text)
  }
}

// MARK: - Accessibility

extension Node where Context: HTML.BodyContext {
  /// Assign an accessibility label to the element, which is used by
  /// assistive technologies to get a text representation of it.
  /// - parameter label: The label to assign.
  /// - Returns: The created node.
  public static func ariaLabel(_ label: String) -> Node {
    .attribute(named: "aria-label", value: label)
  }

  /// Assign an accessibility attribute to an element,
  /// to establish a parent -> child relationship
  /// - parameter child: The child to assign to the parent
  /// - Returns: The created node.
  public static func ariaControls(_ child: String) -> Node {
    .attribute(named: "aria-controls", value: child)
  }

  /// Assign an accessibility attribute to an element,
  /// which describes whether the element is expanded or not
  /// - parameter isExpanded: Whether the element is expanded or not
  /// - Returns: The created node.
  public static func ariaExpanded(_ isExpanded: Bool) -> Node {
    .attribute(named: "aria-expanded", value: isExpanded ? "true" : "false")
  }

  /// Assign an accessibility attribute to an element,
  /// which removes an element from the accessibility tree
  /// - parameter isHidden: Whether the element is hidden or not
  /// - Returns: The created node.
  public static func ariaHidden(_ isHidden: Bool) -> Node {
    .attribute(named: "aria-hidden", value: isHidden ? "true" : "false")
  }
}

// MARK: - Subresource Integrity

extension Attribute where Context: HTMLIntegrityContext {
  /// Assign a subresouce integrity hash to the element, using its `integrity` attribute.
  /// - parameter hash: base64-encoded cryptographic hash
  /// - Returns: The created attribute.
  public static func integrity(_ hash: String) -> Attribute {
    Attribute(name: "integrity", value: hash)
  }
}

extension Node where Context: HTMLIntegrityContext {
  /// Assign a subresouce integrity hash to the element, using its `integrity` attribute.
  /// - parameter hash: base64-encoded cryptographic hash
  /// - Returns: The created node.
  public static func integrity(_ hash: String) -> Node {
    .attribute(named: "integrity", value: hash)
  }
}

// MARK: - Scripts

extension Node where Context == HTML.ScriptContext {
  /// Assign that the element's script should be loaded in `async` mode.
  public static func async() -> Node {
    .attribute(named: "async", value: nil, ignoreIfValueIsEmpty: false)
  }

  /// Assign that the element's script should be loaded in `defer` mode.
  public static func `defer`() -> Node {
    .attribute(named: "defer", value: nil, ignoreIfValueIsEmpty: false)
  }
}

// MARK: - Javascript

extension Node where Context: HTML.BodyContext {
  /// Add a script to execute when the user clicks the current element.
  /// - parameter script: The script to execute when the user clicks on the node.
  ///   Usually prefixed with `javascript:`.
  /// - Returns: The created node.
  public static func onclick(_ script: String) -> Node {
    .attribute(named: "onclick", value: script)
  }
}
