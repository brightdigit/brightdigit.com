/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Component that represents a row within a table.
///
/// You typically only use this component to create the content for a `Table`
/// component, although it can also be used by itself, as long as it's wrapped
/// within an appropriate parent element (such as `<table>` or `<tbody>`).
///
/// Any component that appears within the row's `content` closure that isn't
/// either a `TableCell` (for standard/footer rows) or `TableHeaderCell` (for
/// header rows) is automatically wrapped into such a component instance.
public struct TableRow: ComponentContainer {
  /// A closure that provides the components that the row should contain.
  @ComponentBuilder public var content: ContentProvider
  fileprivate var isHeader = false

  /// The content and behavior of this component.
  public var body: Component {
    Node.tr(
      .forEach(content()) {
        .component(wrap($0))
      }
    )
  }

  /// Create a new instance with the given content.
  public init(@ComponentBuilder content: @escaping ContentProvider) {
    self.content = content
  }

  internal func convertToHeaderNode() -> Node<HTML.TableContext> {
    var row = self
    row.isHeader = true
    return row.convertToNode()
  }

  private func wrap(_ component: Component) -> Component {
    if isHeader {
      return component.wrappedInElement(named: "th")
    }

    return component.wrappedInElement(named: "td")
  }
}
