/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

internal struct Renderer {
  internal private(set) var result = ""
  internal private(set) var deferredAttributes = [AnyAttribute]()

  private let indentation: Indentation?
  private var environment: Environment
  private var elementWrapper: ElementWrapper?
  private var elementBuffer: ElementRenderingBuffer?
  private var containsElement = false
}

extension Renderer {
  internal init(indentationKind: Indentation.Kind?) {
    self.indentation = indentationKind.map(Indentation.init)
    self.environment = Environment()
  }

  internal static func render(
    _ node: AnyNode,
    indentedBy indentationKind: Indentation.Kind?
  ) -> String {
    var renderer = Renderer(indentationKind: indentationKind)
    node.render(into: &renderer)
    return renderer.result
  }

  internal mutating func renderRawText(_ text: String) {
    renderRawText(text, isPlainText: true, wrapIfNeeded: true)
  }

  internal mutating func renderText(_ text: String) {
    renderRawText(text.escaped())
  }

  internal mutating func renderElement<T>(_ element: Element<T>) {
    if let wrapper = elementWrapper {
      guard element.name == wrapper.wrappingElementName else {
        if deferredAttributes.isEmpty {
          return renderComponent(
            wrapper.body(Node.element(element)),
            deferredAttributes: wrapper.deferredAttributes
          )
        } else {
          return renderComponent(
            wrapper.body(
              ModifiedComponent(
                base: Node.element(element),
                deferredAttributes: deferredAttributes
              )
            )
          )
        }
      }
    }

    let buffer = ElementRenderingBuffer(
      element: element,
      indentation: indentation
    )

    var renderer = Renderer(
      indentation: indentation?.indented(),
      environment: environment,
      elementBuffer: buffer
    )

    for node in element.nodes {
      node.render(into: &renderer)
    }

    deferredAttributes.forEach(buffer.add)
    elementBuffer?.containsChildElements = true
    containsElement = true

    renderRawText(
      buffer.flush(),
      isPlainText: false,
      wrapIfNeeded: false
    )
  }

  internal mutating func renderAttribute<T>(_ attribute: Attribute<T>) {
    if let elementBuffer = elementBuffer {
      elementBuffer.add(attribute)
    } else {
      result.append(attribute.render())
    }
  }

  internal mutating func renderComponent(
    _ component: Component,
    deferredAttributes: [AnyAttribute] = [],
    environmentOverrides: [Environment.Override] = [],
    elementWrapper: ElementWrapper? = nil
  ) {
    var environment = self.environment
    for environmentOverride in environmentOverrides {
      environmentOverride.apply(to: &environment)
    }

    if !(component is AnyNode || component is AnyElement) {
      let componentMirror = Mirror(reflecting: component)

      for property in componentMirror.children {
        if let environmentValue = property.value as? AnyEnvironmentValue {
          environmentValue.environment.value = environment
        }
      }
    }

    var renderer = Renderer(
      deferredAttributes: deferredAttributes,
      indentation: indentation,
      environment: environment,
      elementWrapper: elementWrapper
    )

    if let node = component as? AnyNode {
      node.render(into: &renderer)
    } else {
      renderer.renderComponent(
        component.body,
        deferredAttributes: deferredAttributes,
        elementWrapper: elementWrapper ?? self.elementWrapper
      )
    }

    renderRawText(
      renderer.result,
      isPlainText: !renderer.containsElement,
      wrapIfNeeded: false
    )

    containsElement = renderer.containsElement
  }
}

extension Renderer {
  fileprivate mutating func renderRawText(
    _ text: String,
    isPlainText: Bool,
    wrapIfNeeded: Bool
  ) {
    if wrapIfNeeded {
      if let wrapper = elementWrapper {
        return renderComponent(wrapper.body(Node<Any>.raw(text)))
      }
    }

    if let elementBuffer = elementBuffer {
      elementBuffer.add(text, isPlainText: isPlainText)
    } else {
      if indentation != nil && !result.isEmpty {
        result.append("\n")
      }

      result.append(text)
    }
  }
}
