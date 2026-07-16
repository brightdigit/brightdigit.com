/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct ModifierCollection: Sendable {
  private var modifiers: [Modifier.Target: [Modifier]]

  internal init(modifiers: [Modifier]) {
    self.modifiers = Dictionary(grouping: modifiers, by: { $0.target })
  }

  internal func applyModifiers(
    for target: Modifier.Target,
    using closure: (Modifier) -> Void
  ) {
    modifiers[target]?.forEach(closure)
  }

  internal mutating func insert(_ modifier: Modifier) {
    modifiers[modifier.target, default: []].append(modifier)
  }
}
