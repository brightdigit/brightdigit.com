/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// A container component that's rendered using the `<article>` element.
public typealias Article = ElementComponent<ElementDefinitions.Article>
/// A container component that's rendered using the `<aside>` element.
public typealias Aside = ElementComponent<ElementDefinitions.Aside>
/// A container component that's rendered using the `<button>` element.
public typealias Button = ElementComponent<ElementDefinitions.Button>
/// A container component that's rendered using the `<div>` element.
public typealias Details = ElementComponent<ElementDefinitions.Details>
/// A container component that's rendered using the `<div>` element.
public typealias Div = ElementComponent<ElementDefinitions.Div>
/// A container component that's rendered using the `<fieldset>` element.
public typealias FieldSet = ElementComponent<ElementDefinitions.FieldSet>
/// A container component that's rendered using the `<footer>` element.
public typealias Footer = ElementComponent<ElementDefinitions.Footer>
// The HTML heading type names H1...H6 are two characters by design and are
// public API, so they cannot be renamed to satisfy `type_name`.
// swiftlint:disable type_name
/// A container component that's rendered using the `<h1>` element.
public typealias H1 = ElementComponent<ElementDefinitions.H1>
/// A container component that's rendered using the `<h2>` element.
public typealias H2 = ElementComponent<ElementDefinitions.H2>
/// A container component that's rendered using the `<h3>` element.
public typealias H3 = ElementComponent<ElementDefinitions.H3>
/// A container component that's rendered using the `<h4>` element.
public typealias H4 = ElementComponent<ElementDefinitions.H4>
/// A container component that's rendered using the `<h5>` element.
public typealias H5 = ElementComponent<ElementDefinitions.H5>
/// A container component that's rendered using the `<h6>` element.
public typealias H6 = ElementComponent<ElementDefinitions.H6>
// swiftlint:enable type_name
/// A container component that's rendered using the `<header>` element.
public typealias Header = ElementComponent<ElementDefinitions.Header>
/// A container component that's rendered using the `<li>` element.
public typealias ListItem = ElementComponent<ElementDefinitions.ListItem>
/// A container component that's rendered using the `<main>` element.
public typealias Main = ElementComponent<ElementDefinitions.Main>
/// A container component that's rendered using the `<nav>` element.
public typealias Navigation = ElementComponent<ElementDefinitions.Navigation>
/// A container component that's rendered using the `<p>` element.
public typealias Paragraph = ElementComponent<ElementDefinitions.Paragraph>
/// A container component that's rendered using the `<span>` element.
public typealias Span = ElementComponent<ElementDefinitions.Span>
/// A container component that's rendered using the `<summary>` element.
public typealias Summary = ElementComponent<ElementDefinitions.Summary>
/// A container component that's rendered using the `<caption>` element.
public typealias TableCaption = ElementComponent<ElementDefinitions.TableCaption>
/// A container component that's rendered using the `<td>` element.
public typealias TableCell = ElementComponent<ElementDefinitions.TableCell>
/// A container component that's rendered using the `<th>` element.
public typealias TableHeaderCell = ElementComponent<ElementDefinitions.TableHeaderCell>

/// Enum namespace that contains Plot's built-in `ElementDefinition` implementations.
public enum ElementDefinitions {
  /// Definition for the `<article>` element.
  public enum Article: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.article
  }
  /// Definition for the `<aside>` element.
  public enum Aside: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.aside
  }
  /// Definition for the `<button>` element.
  public enum Button: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.button
  }
  /// Definition for the `<details>` element.
  public enum Details: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.details
  }
  /// Definition for the `<div>` element.
  public enum Div: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node<HTML.BodyContext>.div
  }
  /// Definition for the `<fieldset>` element.
  public enum FieldSet: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.fieldset
  }
  /// Definition for the `<footer>` element.
  public enum Footer: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.footer
  }
  // The HTML heading type names H1...H6 are two characters by design and are
  // public API, so they cannot be renamed to satisfy `type_name`.
  // swiftlint:disable type_name
  /// Definition for the `<h1>` element.
  public enum H1: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.h1
  }
  /// Definition for the `<h2>` element.
  public enum H2: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.h2
  }
  /// Definition for the `<h3>` element.
  public enum H3: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.h3
  }
  /// Definition for the `<h4>` element.
  public enum H4: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.h4
  }
  /// Definition for the `<h5>` element.
  public enum H5: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.h5
  }
  /// Definition for the `<h6>` element.
  public enum H6: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.h6
  }
  // swiftlint:enable type_name
  /// Definition for the `<header>` element.
  public enum Header: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.header
  }
  /// Definition for the `<li>` element.
  public enum ListItem: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.li
  }
  /// Definition for the `<main>` element.
  public enum Main: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.main
  }
  /// Definition for the `<nav>` element.
  public enum Navigation: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.nav
  }
  /// Definition for the `<p>` element.
  public enum Paragraph: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.p
  }
  /// Definition for the `<span>` element.
  public enum Span: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.span
  }
  /// Definition for the `<summary>` element.
  public enum Summary: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.summary
  }
  /// Definition for the `<caption>` element.
  public enum TableCaption: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.caption
  }
  /// Definition for the `<td>` element.
  public enum TableCell: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.td
  }
  /// Definition for the `<th>` element.
  public enum TableHeaderCell: ElementDefinition {
    /// The node that this definition wraps its content within.
    public static let wrapper = Node.th
  }
}

extension ListItem {
  /// Assign an explicit number for the item when it appears in an
  /// ordered list. Maps to the `value` attribute.
  /// - parameter number: The number to apply.
  /// - Returns: The resulting component.
  public func number(_ number: Int) -> Component {
    attribute(named: "value", value: String(number))
  }
}

// MARK: - Component implementations
