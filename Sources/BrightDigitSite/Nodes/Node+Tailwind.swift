//
//  Node+Tailwind.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Plot
import TailwindKit

// TailwindKit depends on no HTML library; it exposes the `TailwindClassAttribute`
// seam instead, and the consumer supplies the binding. These conformances are
// that binding for Plot — they are what makes `.tailwind(…)` available on
// `Node`/`Attribute` throughout the site.

extension Node: TailwindClassAttribute where Context: HTMLContext {
  /// Creates a `class` attribute node set to `className`.
  public static func tailwindClass(_ className: String) -> Node {
    .class(className)
  }
}

extension Attribute: TailwindClassAttribute where Context: HTMLContext {
  /// Creates a `class` attribute set to `className`.
  public static func tailwindClass(_ className: String) -> Attribute {
    .class(className)
  }
}

extension Component {
  /// Renders a `TailwindStyleBuilder` into this component's `class` attribute.
  ///
  /// `Component` cannot go through ``TailwindKit/TailwindClassAttribute``: Swift
  /// does not allow retroactively conforming one protocol to another, and Plot's
  /// `class(_:replaceExisting:)` returns an existential rather than `Self`. So
  /// the instance sugar is written directly here.
  ///
  /// - Parameters:
  ///   - style: The Tailwind style to render.
  ///   - replaceExisting: Whether the rendered classes replace any existing
  ///     `class` value. Defaults to `false`, appending instead.
  /// - Returns: The resulting component.
  public func tailwind(
    _ style: TailwindStyleBuilder,
    replaceExisting: Bool = false
  ) -> Component {
    self.class(style.rendered, replaceExisting: replaceExisting)
  }
}
