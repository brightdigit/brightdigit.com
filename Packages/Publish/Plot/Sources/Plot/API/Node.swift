/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// A representation of a node within a document's hierarchy.
///
/// Plot treats all elements and attributes that a document contains
/// as nodes. When using the Plot DSL, each time you create a new
/// element, or add an attribute to an existing one, you are creating
/// a node. Nodes can also contain just text, which can either be
/// escaped or treated as raw, pre-processed text. Groups can also be
/// created to form components.
public struct Node<Context> {
  internal let rendering: (inout Renderer) -> Void
}

extension Node {
  /// An empty node, which won't be rendered.
  public static var empty: Node { Node { _ in } }

  /// Create a node from a raw piece of text that should be rendered as-is.
  /// - parameter text: The raw text that the node should contain.
  /// - Returns: The created node.
  public static func raw(_ text: String) -> Node {
    Node { $0.renderRawText(text) }
  }

  /// Create a node from a piece of free-form text that should be escaped.
  /// - parameter text: The text that the node should contain.
  /// - Returns: The created node.
  public static func text(_ text: String) -> Node {
    Node { $0.renderText(text) }
  }

  /// Create a node representing an element
  /// - parameter element: The element that the node should contain.
  /// - Returns: The created node.
  public static func element(_ element: Element<Context>) -> Node {
    Node { $0.renderElement(element) }
  }

  /// Create a custom element with a given name.
  /// - parameter name: The name of the element to create.
  /// - Returns: The created node.
  public static func element(named name: String) -> Node {
    .element(Element(name: name, nodes: []))
  }

  /// Create a custom element with a given name and an array of child nodes.
  /// - Parameters:
  ///   - name: The name of the element to create.
  ///   - nodes: The nodes (child elements + attributes) to add to the element.
  /// - Returns: The created node.
  public static func element(named name: String, nodes: [Node]) -> Node {
    .element(Element(name: name, nodes: nodes))
  }

  /// Create a custom element with a given name and an array of child nodes.
  /// - Parameters:
  ///   - name: The name of the element to create.
  ///   - nodes: The nodes (child elements + attributes) to add to the element.
  /// - Returns: The created node.
  public static func element<C>(named name: String, nodes: [Node<C>]) -> Node {
    .element(Element(name: name, nodes: nodes))
  }

  /// Create a custom element with a given name and text content.
  /// - Parameters:
  ///   - name: The name of the element to create.
  ///   - text: The text to use as the node's content.
  /// - Returns: The created node.
  public static func element(named name: String, text: String) -> Node {
    .element(Element(name: name, nodes: [Node.text(text)]))
  }

  /// Create a custom element with a given name and an array of attributes.
  /// - Parameters:
  ///   - name: The name of the element to create.
  ///   - attributes: The attributes to add to the element.
  /// - Returns: The created node.
  public static func element<C>(named name: String, attributes: [Attribute<C>]) -> Node {
    .element(Element(name: name, nodes: attributes.map(\.node)))
  }

  /// Create a custom element with a given name and an array of attributes.
  /// - Parameters:
  ///   - name: The name of the element to create.
  ///   - attributes: The attributes to add to the element.
  /// - Returns: The created node.
  public static func element(named name: String, attributes: [Attribute<Context>]) -> Node {
    .element(Element(name: name, nodes: attributes.map(\.node)))
  }

  /// Create a custom self-closed element with a given name.
  /// - parameter name: The name of the element to create.
  /// - Returns: The created node.
  public static func selfClosedElement(named name: String) -> Node {
    .element(Element(name: name, closingMode: .selfClosing, nodes: []))
  }

  /// Create a custom self-closed element with a given name and an array of attributes.
  /// - Parameters:
  ///   - name: The name of the element to create.
  ///   - attributes: The attributes to add to the element.
  /// - Returns: The created node.
  public static func selfClosedElement<C>(named name: String, attributes: [Attribute<C>]) -> Node {
    .element(Element(name: name, closingMode: .selfClosing, nodes: attributes.map(\.node)))
  }

  /// Create a custom self-closed element with a given name and an array of attributes.
  /// - Parameters:
  ///   - name: The name of the element to create.
  ///   - attributes: The attributes to add to the element.
  /// - Returns: The created node.
  public static func selfClosedElement(named name: String, attributes: [Attribute<Context>]) -> Node
  {
    .element(Element(name: name, closingMode: .selfClosing, nodes: attributes.map(\.node)))
  }

  /// Create a node that represents an attribute.
  /// - parameter attribute: The attribute that the node should contain.
  /// - Returns: The created node.
  public static func attribute(_ attribute: Attribute<Context>) -> Node {
    Node { $0.renderAttribute(attribute) }
  }

  /// Create a custom attribute with a given name.
  /// - parameter name: The name of the attribute to create.
  /// - Returns: The created node.
  public static func attribute(named name: String) -> Node {
    .attribute(
      Attribute(
        name: name,
        value: nil,
        ignoreIfValueIsEmpty: false
      )
    )
  }

  /// Create a custom attribute with a given name and value.
  /// - Parameters:
  ///   - name: The name of the attribute to create.
  ///   - value: The attribute's value.
  ///   - ignoreIfValueIsEmpty: Whether the attribute should be ignored if
  ///     its value is empty (default: true).
  /// - Returns: The created node.
  public static func attribute(
    named name: String,
    value: String?,
    ignoreIfValueIsEmpty: Bool = true
  ) -> Node {
    .attribute(
      Attribute(
        name: name,
        value: value,
        ignoreIfValueIsEmpty: ignoreIfValueIsEmpty
      )
    )
  }

  /// Create a group of nodes from an array.
  /// - parameter members: The nodes that should be included in the group.
  /// - Returns: The created node.
  public static func group(_ members: [Node]) -> Node {
    Node { renderer in
      for member in members {
        member.render(into: &renderer)
      }
    }
  }

  /// Create a group of nodes using variadic parameter syntax.
  /// - parameter members: The nodes that should be included in the group.
  /// - Returns: The created node.
  public static func group(_ members: Node...) -> Node {
    .group(members)
  }

  /// Create a node that wraps a `Component`. You can use this API to
  /// integrate a component into a `Node`-based hierarchy.
  /// - parameter component: The component that should be wrapped.
  /// - Returns: The created node.
  public static func component(_ component: Component) -> Node {
    Node { $0.renderComponent(component) }
  }

  /// Create a node that wraps a set of components defined within a closure. You
  /// can use this API to integrate a group of components into a `Node`-based hierarchy.
  /// - parameter content: A closure that creates a group of components.
  /// - Returns: The created node.
  public static func components(@ComponentBuilder _ content: () -> Component) -> Node {
    .component(content())
  }
}
