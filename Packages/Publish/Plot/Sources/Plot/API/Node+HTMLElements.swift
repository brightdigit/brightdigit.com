/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Node where Context: HTMLContext {
  /// Add an HTML comment within the current context.
  /// - parameter text: The comment's text.
  /// - Returns: The created node.
  public static func comment(_ text: String) -> Node {
    .group(.raw("<!--"), .text(text), .raw("-->"))
  }
}

// MARK: - Root

extension Element where Context == HTML.RootContext {
  /// Add an HTML `!DOCTYPE` declaration to the document.
  /// - parameter type: The type of document to declare.
  /// You typically never have to call this API yourself, since Plot
  /// will automatically add this declaration at the top of all HTML
  /// documents that are created using the `HTML` type's initializer.
  /// - Returns: The created element.
  public static func doctype(_ type: String) -> Element {
    Element(
      name: "!DOCTYPE",
      closingMode: .neverClosed,
      nodes: [
        Node<HTML.RootContext>.attribute(named: type)
      ]
    )
  }

  /// Add a root `<html>` element to the document.
  /// - parameter nodes: The element's attributes and child elements.
  /// You typically never have to call this API yourself, since Plot
  /// will automatically add this element at the root of all HTML
  /// documents that are created using the `HTML` type's initializer.
  /// - Returns: The created element.
  public static func html(_ nodes: Node<HTML.DocumentContext>...) -> Element {
    Element(name: "html", nodes: nodes)
  }
}

// MARK: - Document

extension Node where Context == HTML.DocumentContext {
  /// Add a `<head>` HTML element within the current context, which
  /// contains non-visual elements, such as stylesheets and metadata.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func head(_ nodes: Node<HTML.HeadContext>...) -> Node {
    .element(named: "head", nodes: nodes)
  }

  /// Add a `<body>` HTML element within the current context, which
  /// makes up the renderable body of the page.
  /// - parameter nodes: The element's attributes and child elements.
  /// - Returns: The created node.
  public static func body(_ nodes: Node<HTML.BodyContext>...) -> Node {
    .element(named: "body", nodes: nodes)
  }

  /// Add a `<body>` HTML element within the current context, which
  /// makes up the renderable body of the page, and populate that element
  /// with a set of components.
  /// - parameter content: A closure that creates the components that
  ///   should make up this element's content.
  /// - Returns: The created node.
  public static func body(@ComponentBuilder _ content: @escaping () -> Component) -> Node {
    .body(.component(content()))
  }
}

// MARK: - Head

extension Node where Context == HTML.HeadContext {
  /// Add a `<link/>` HTML element within the current context.
  /// - parameter attributes: The element's attributes.
  /// - Returns: The created node.
  public static func link(_ attributes: Attribute<HTML.LinkContext>...) -> Node {
    .selfClosedElement(named: "link", attributes: attributes)
  }

  /// Add a `<meta/>` HTML element within the current context.
  /// - parameter attributes: The element's attributes.
  /// - Returns: The created node.
  public static func meta(_ attributes: Attribute<HTML.MetaContext>...) -> Node {
    .selfClosedElement(named: "meta", attributes: attributes)
  }

  /// Add a `<style>` HTML element within the current context.
  /// - parameter css: The CSS code that the element should contain.
  /// - Returns: The created node.
  public static func style(_ css: String) -> Node {
    .element(named: "style", nodes: [.raw(css)])
  }
}

// MARK: - Body
