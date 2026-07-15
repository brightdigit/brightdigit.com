/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Node where Context: DocumentFormat {
  internal static func document(_ document: Document<Context>) -> Node {
    Node { renderer in
      for element in document.elements {
        renderer.renderElement(element)
      }
    }
  }
}

extension Node where Context == Any {
  internal static func modifiedComponent(_ component: ModifiedComponent) -> Node {
    Node { renderer in
      renderer.renderComponent(
        component.base,
        deferredAttributes: component.deferredAttributes + renderer.deferredAttributes,
        environmentOverrides: component.environmentOverrides
      )
    }
  }

  internal static func components(_ components: [Component]) -> Node {
    Node { renderer in
      for component in components {
        renderer.renderComponent(
          component,
          deferredAttributes: renderer.deferredAttributes
        )
      }
    }
  }

  internal static func wrappingComponent(
    _ component: Component,
    using wrapper: ElementWrapper
  ) -> Node {
    Node { renderer in
      var wrapper = wrapper
      wrapper.deferredAttributes = renderer.deferredAttributes

      renderer.renderComponent(
        component,
        elementWrapper: wrapper
      )
    }
  }
}

extension Node: NodeConvertible {
  /// The node representation of this value.
  public var node: Self { self }

  /// Render this node into a string.
  /// - Returns: The rendered string.
  public func render(indentedBy indentationKind: Indentation.Kind?) -> String {
    Renderer.render(self, indentedBy: indentationKind)
  }
}

extension Node: Component {
  /// The content and behavior of this component.
  public var body: Component { self }
}

extension Node: ExpressibleByStringInterpolation {
  /// Create a node using the given string literal.
  public init(stringLiteral value: String) {
    self = .text(value)
  }
}

extension Node: AnyNode {
  internal func render(into renderer: inout Renderer) {
    rendering(&renderer)
  }
}
