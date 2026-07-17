/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Node where Context: HTML.BodyContext {
  /// Add a `<hr/>` HTML element within the current context.
  /// - parameter attributes: The element's attributes.
  /// - Returns: The created node.
  public static func hr(_ attributes: Attribute<HTML.BodyContext>...) -> Node {
    .selfClosedElement(named: "hr", attributes: attributes)
  }

  /// Add an `<i>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func i(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "i", nodes: nodes)
  }

  /// Add an `<iframe>` HTML element within the current context.
  /// - parameter attributes: The element's attributes.
  /// - Returns: The created node.
  public static func iframe(_ attributes: Attribute<HTML.IFrameContext>...) -> Node {
    .element(named: "iframe", attributes: attributes)
  }

  /// Add an `<input/>` HTML element within the current context.
  /// - parameter attributes: The element's attributes.
  /// - Returns: The created node.
  public static func input(_ attributes: Attribute<HTML.InputContext>...) -> Node {
    .selfClosedElement(named: "input", attributes: attributes)
  }

  /// Add an `<ins>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func ins(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "ins", nodes: nodes)
  }

  /// Add a `<label>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func label(_ nodes: Node<HTML.LabelContext>...) -> Node {
    .element(named: "label", nodes: nodes)
  }

  /// Add a `<main>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func main(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "main", nodes: nodes)
  }

  /// Add a `<nav>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func nav(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "nav", nodes: nodes)
  }

  /// Add a `<noscript>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func noscript(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "noscript", nodes: nodes)
  }

  /// Add an `<object>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func object(_ nodes: Node<HTML.ObjectContext>...) -> Node {
    .element(named: "object", nodes: nodes)
  }

  /// Add an `<ol>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func ol(_ nodes: Node<HTML.ListContext>...) -> Node {
    .element(named: "ol", nodes: nodes)
  }

  /// Add a `<p>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func p(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "p", nodes: nodes)
  }

  /// Add a `<picture>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func picture(_ nodes: Node<HTML.PictureContext>...) -> Node {
    .element(named: "picture", nodes: nodes)
  }

  /// Add a `<pre>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func pre(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "pre", nodes: nodes)
  }

  /// Add an `<s>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func s(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "s", nodes: nodes)
  }

  /// Add a `<section>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func section(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "section", nodes: nodes)
  }

  /// Add a `<select>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func select(_ nodes: Node<HTML.SelectContext>...) -> Node {
    .element(named: "select", nodes: nodes)
  }

  /// Add a `<small>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func small(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "small", nodes: nodes)
  }

  /// Add a `<span>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func span(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "span", nodes: nodes)
  }

  /// Add a `<strong>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func strong(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "strong", nodes: nodes)
  }

  /// Add a `<table>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func table(_ nodes: Node<HTML.TableContext>...) -> Node {
    .element(named: "table", nodes: nodes)
  }

  /// Add a `<textarea>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and nodes.
  /// - Returns: The created node.
  public static func textarea(_ nodes: Node<HTML.TextAreaContext>...) -> Node {
    .element(named: "textarea", nodes: nodes)
  }

  /// Add a `<time>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and nodes.
  /// - Returns: The created node.
  public static func time(_ nodes: Node<HTML.TimeContext>...) -> Node {
    .element(named: "time", nodes: nodes)
  }

  /// Add a `<u>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func u(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "u", nodes: nodes)
  }

  /// Add a `<ul>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func ul(_ nodes: Node<HTML.ListContext>...) -> Node {
    .element(named: "ul", nodes: nodes)
  }

  /// Add a `<video>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func video(_ nodes: Node<HTML.VideoContext>...) -> Node {
    .element(named: "video", nodes: nodes)
  }
}
