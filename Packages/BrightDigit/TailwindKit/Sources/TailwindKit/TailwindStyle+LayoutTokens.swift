//
//  TailwindStyle+LayoutTokens.swift
//  TailwindKit
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

extension TailwindStyle {
  /// An `object-fit` keyword (the `cover` in `object-cover`).
  ///
  /// A fixed CSS keyword set (`object-fit` has no theme namespace), so a closed
  /// enum.
  public enum ObjectFit: String, Sendable, CaseIterable {
    case contain, cover, fill, none
    case scaleDown = "scale-down"

    internal var token: String { rawValue }
  }

  /// A `vertical-align` keyword (the `middle` in `align-middle`).
  public enum VerticalAlign: String, Sendable, CaseIterable {
    case baseline, top, middle, bottom
    case textTop = "text-top"
    case textBottom = "text-bottom"
    case sub, `super`

    internal var token: String { rawValue }
  }

  /// A single box side for `border-{t,r,b,l}-<n>` width utilities.
  public enum BorderSide: String, Sendable, CaseIterable {
    case top = "t"
    case right = "r"
    case bottom = "b"
    case left = "l"

    internal var token: String { rawValue }
  }

  /// A `position` keyword (the whole class, e.g. `relative`, `absolute`).
  ///
  /// The class name *is* the token — Tailwind's position utilities carry no
  /// prefix — consumed by ``TailwindStyle/position(_:)``.
  public enum Position: String, Sendable, CaseIterable {
    case relative, absolute, fixed, sticky

    internal var token: String { rawValue }
  }

  /// A `flex` shorthand value (the `1` in `flex-1`, or `flex-none`).
  public enum Flex: String, Sendable, CaseIterable {
    /// `flex-1` — grow and shrink, ignoring the initial size.
    case one = "1"
    /// `flex-auto` — grow and shrink, accounting for the initial size.
    case auto
    /// `flex-initial` — shrink but don't grow.
    case initial
    /// `flex-none` — neither grow nor shrink.
    case none

    internal var token: String { rawValue }
  }

  /// A `flex-direction` keyword (the `col` in `flex-col`,
  /// `row-reverse` in `flex-row-reverse`).
  public enum FlexDirection: String, Sendable, CaseIterable {
    case row, col
    case rowReverse = "row-reverse"
    case colReverse = "col-reverse"

    internal var token: String { rawValue }
  }

  /// A `list-style` keyword — both the marker type (`disc`, `decimal`,
  /// `none`) and its position (`inside`, `outside`) — all `list-*` utilities.
  public enum ListStyle: String, Sendable, CaseIterable {
    case disc, decimal, none, inside, outside

    internal var token: String { rawValue }
  }
}
