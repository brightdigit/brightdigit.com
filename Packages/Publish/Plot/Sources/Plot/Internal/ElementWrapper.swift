/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import Foundation

internal struct ElementWrapper {
  internal var wrappingElementName: String
  internal var deferredAttributes = [AnyAttribute]()
  internal var body: (Component) -> Component
}

extension ElementWrapper {
  internal init(wrappingElementName: String) {
    self.wrappingElementName = wrappingElementName
    self.body = {
      Element(
        name: wrappingElementName,
        nodes: [
          Node<Any>.component($0)
        ]
      )
    }
  }
}
