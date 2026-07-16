/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

internal struct ModifiedComponent: Component {
  internal var base: Component
  internal var deferredAttributes = [AnyAttribute]()
  internal var environmentOverrides = [Environment.Override]()
  internal var body: Component { Node.modifiedComponent(self) }
}
