/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// A representation of an HTML document. Create an instance of this
/// type to build a web page using Plot's type-safe DSL, and then
/// call the `render()` method to turn it into an HTML string.
public struct HTML: DocumentFormat {
  private let document: Document<HTML>
  private var environmentOverrides = [Environment.Override]()

  /// Create an HTML document with a collection of nodes that make
  /// up its elements and attributes. Start by specifying its root
  /// nodes, such as `.head()` and `.body()`, and then create any
  /// sort of hierarchy of elements and attributes from there.
  /// - parameter nodes: The root nodes of the document, which will
  /// be placed inside of an `<html>` element.
  public init(_ nodes: Node<HTML.DocumentContext>...) {
    document = Document(elements: [
      .doctype("html"),
      .html(.group(nodes)),
    ])
  }
}

extension HTML {
  /// Create an HTML document with a set of `<head>` nodes and a closure
  /// that defines the components that should make up its `<body>`.
  /// - Parameters:
  ///   - head: The nodes that should be placed within this HTML
  ///     document's `<head>` element.
  ///   - body: A closure that defines a set of components that
  ///     should be placed within this HTML document's `<body>` element.
  public init(
    head: [Node<HTML.HeadContext>] = [],
    @ComponentBuilder body: @escaping () -> Component
  ) {
    self.init(
      .if(!head.isEmpty, .head(.group(head))),
      .body(body)
    )
  }

  /// Place a value into the environment used to render this HTML document and
  /// any components within it. An environment value will be passed downwards
  /// through a component/node hierarchy until its overriden by another value
  /// for the same key.
  /// - Parameters:
  ///   - value: The value to add. Must match the type of the key that
  ///     it's being added for. This value will override any value that was assigned
  ///     by a parent component for the same key, or the key's default value.
  ///   - key: The key to associate the value wth. You can either use any
  ///     of the built-in key definitions that Plot ships with, or define your own.
  ///     See `EnvironmentKey` for more information.
  /// - Returns: The resulting HTML document.
  public func environmentValue<T>(_ value: T, key: EnvironmentKey<T>) -> HTML {
    var html = self
    html.environmentOverrides.append(.init(key: key, value: value))
    return html
  }
}

extension HTML: NodeConvertible {
  /// The node representation of this document.
  public var node: Node<Self> {
    if environmentOverrides.isEmpty {
      return document.node
    }

    return ModifiedComponent(
      base: document.node,
      environmentOverrides: environmentOverrides
    )
    .convertToNode()
  }
}

extension HTML {
  /// The root context of an HTML document. Plot automatically
  /// creates all required elements within this context for you.
  public enum RootContext {}
  /// The user-facing root context of an HTML document. Elements
  /// like `<head>` and `<body>` are placed within this context.
  public enum DocumentContext: HTMLStylableContext {}
  /// The context within an HTML document's `<head>` element.
  public enum HeadContext: HTMLContext, HTMLScriptableContext {}
  /// The context within an HTML document's `<body>` element.
  public class BodyContext: HTMLStylableContext, HTMLScriptableContext, HTMLImageContainerContext,
    HTMLDividableContext
  {}
  /// The context within an HTML `<a>` element.
  public final class AnchorContext: BodyContext, HTMLLinkableContext {}
  /// The context within an HTML `<audio>` element.
  public enum AudioContext: HTMLMediaContext {
    /// The context type used within this element's source elements.
    public typealias SourceContext = AudioSourceContext
  }
  /// The context within an audio `<source>` element.
  public enum AudioSourceContext: HTMLSourceContext {}
  /// The context within an HTML `<button>` element.
  public final class ButtonContext: BodyContext, HTMLNamableContext, HTMLValueContext {}
  /// The context within an HTML `<data>` element.
  public class DataContext: BodyContext, HTMLValueContext {}
  /// The context within an HTML `<datalist>` element.
  public enum DataListContext: HTMLOptionListContext {}
  /// The context within an HTML `<dl>` element.
  public enum DescriptionListContext: HTMLStylableContext, HTMLDividableContext {}
  /// The context within an HTML `<details>` element.
  public final class DetailsContext: BodyContext {}
  /// The context within an HTML `<embed>` element.
  public enum EmbedContext: HTMLStylableContext, HTMLSourceContext, HTMLTypeContext,
    HTMLDimensionContext
  {}
  /// The context within an HTML `<form>` element.
  public final class FormContext: BodyContext {}
  /// The context within an HTML `<iframe>` element.
  public enum IFrameContext: HTMLNamableContext, HTMLSourceContext {}
  /// The context within an HTML `<img>` element.
  public enum ImageContext: HTMLSourceContext, HTMLStylableContext, HTMLDimensionContext {}
  /// The context within an HTML `<input>` element.
  public enum InputContext: HTMLNamableContext, HTMLValueContext {}
  /// The context within an HTML `<textarea>` element.
  public final class TextAreaContext: HTMLNamableContext {}
  /// The context within an HTML `<label>` element.
  public final class LabelContext: BodyContext {}
  /// The context within an HTML `<link>` element.
  public enum LinkContext: HTMLLinkableContext, HTMLTypeContext, HTMLIntegrityContext {}
  /// The context within an HTML list, such as `<ul>` or `<ol>` elements.
  public enum ListContext: HTMLStylableContext {}
  /// The context within an HTML `<meta>` element.
  public enum MetaContext: HTMLNamableContext {}
  /// The contect within an HTML `<object>` element.
  public enum ObjectContext: HTMLDimensionContext, HTMLTypeContext {}
  /// The context within an HTML `<option>` element.
  public enum OptionContext: HTMLValueContext {}
  /// The context within an HTML `<picture>` element.
  public enum PictureContext: HTMLSourceListContext, HTMLImageContainerContext {
    /// The context type used within this element's source elements.
    public typealias SourceContext = PictureSourceContext
  }
  /// The context within a picture `<source>` element.
  public enum PictureSourceContext {}
  /// The context within an HTML `<script>` element.
  public enum ScriptContext: HTMLSourceContext, HTMLIntegrityContext {}
  /// The context within an HTML `<select>` element.
  public enum SelectContext: HTMLOptionListContext {}
  /// The context within an HTML `<table>` element.
  public enum TableContext: HTMLStylableContext {}
  /// The context within an HTML `<tr>` element.
  public enum TableRowContext: HTMLStylableContext {}
  /// The context within an HTML `<time>` element.
  public final class TimeContext: BodyContext {}
  /// The context within an HTML `<video>` element.
  public enum VideoContext: HTMLMediaContext {
    /// The context type used within this element's source elements.
    public typealias SourceContext = VideoSourceContext
  }
  /// The context within a video `<source>` element.
  public enum VideoSourceContext: HTMLSourceContext {}
}
