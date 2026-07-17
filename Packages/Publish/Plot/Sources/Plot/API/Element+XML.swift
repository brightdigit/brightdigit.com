/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Element where Context: XMLRootContext {
  /// Add an XML declaration node within the current context.
  /// - parameter attributes: The declaration's attributes.
  /// - Returns: The created element.
  public static func xml(_ attributes: Attribute<XML.DeclarationContext>...) -> Element {
    Element(
      name: "xml",
      closingMode: .neverClosed,
      nodes: attributes.map(\.node),
      paddingCharacter: "?"
    )
  }
}
