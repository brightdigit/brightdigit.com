/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Node where Context == HTML.ListContext {
  /// Add an `<li>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func li(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "li", nodes: nodes)
  }
}

extension Node where Context == HTML.DescriptionListContext {
  /// Add a `<dd>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func dd(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "dd", nodes: nodes)
  }

  /// Add a `<dt>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func dt(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "dt", nodes: nodes)
  }
}

extension Node where Context: HTMLOptionListContext {
  /// Add an `<option>` HTML element within the current context.
  /// - parameter attributes: The element's attributes.
  /// - Returns: The created node.
  public static func option(_ attributes: Attribute<HTML.OptionContext>...) -> Node {
    .selfClosedElement(named: "option", attributes: attributes)
  }
}

// MARK: - Tables

extension Node where Context == HTML.TableContext {
  /// Add a `<caption>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func caption(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "caption", nodes: nodes)
  }

  /// Add a `<tr>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func tr(_ nodes: Node<HTML.TableRowContext>...) -> Node {
    .element(named: "tr", nodes: nodes)
  }

  /// Add a `<thead>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func thead(_ nodes: Node<HTML.TableContext>...) -> Node {
    .element(named: "thead", nodes: nodes)
  }

  /// Add a `<tbody>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func tbody(_ nodes: Node<HTML.TableContext>...) -> Node {
    .element(named: "tbody", nodes: nodes)
  }

  /// Add a `<tfoot>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func tfoot(_ nodes: Node<HTML.TableContext>...) -> Node {
    .element(named: "tfoot", nodes: nodes)
  }
}

extension Node where Context == HTML.TableRowContext {
  /// Add a `<th>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func th(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "th", nodes: nodes)
  }

  /// Add a `<td>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func td(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "td", nodes: nodes)
  }
}

// MARK: - Media

extension Node where Context: HTMLImageContainerContext {
  /// Add an `<img/>` HTML element within the current context.
  /// - parameter attributes: The element's attributes.
  /// - Returns: The created node.
  public static func img(_ attributes: Attribute<HTML.ImageContext>...) -> Node {
    .selfClosedElement(named: "img", attributes: attributes)
  }
}

extension Node where Context: HTMLSourceListContext {
  /// Add a `<source/>` HTML element within the current context.
  /// - parameter attributes: The element's attributes.
  /// - Returns: The created node.
  public static func source(_ attributes: Attribute<Context.SourceContext>...) -> Node {
    .selfClosedElement(named: "source", attributes: attributes)
  }
}

// MARK: - Other

extension Node where Context == HTML.DetailsContext {
  /// Add a `<summary>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func summary(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "summary", nodes: nodes)
  }
}

extension Node where Context: HTMLScriptableContext {
  /// Add a `<script>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and text content.
  /// - Returns: The created node.
  public static func script(_ nodes: Node<HTML.ScriptContext>...) -> Node {
    .element(named: "script", nodes: nodes)
  }
}

extension Node where Context: HTMLDividableContext {
  /// Add a `<div>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func div(_ nodes: Node<Context>...) -> Node {
    .element(named: "div", nodes: nodes)
  }
}
