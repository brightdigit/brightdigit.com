//
//  DisplayStyling.swift
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

/// The **display** utilities.
///
/// A capability protocol whose members are witnessed against the
/// ``TailwindStyleProtocol`` seam; ``TailwindStyle`` conforms to it. See
/// ``TailwindStyleProtocol`` for why the surface is organized this way.
public protocol DisplayStyling {
  /// `flex`.
  var flex: Self { get }
  /// `inline-flex`.
  var inlineFlex: Self { get }
  /// `grid`.
  var grid: Self { get }
  /// `block`.
  var block: Self { get }
  /// `inline-block`.
  var inlineBlock: Self { get }
  /// `inline`.
  var inline: Self { get }
  /// `hidden`.
  var hidden: Self { get }
  /// `container`.
  var container: Self { get }
  /// `contents`.
  var contents: Self { get }
}

extension DisplayStyling where Self: TailwindStyleProtocol {
  // MARK: Bare

  /// `flex`.
  public var flex: Self { appending(TailwindStyle.DefaultTailwindClass("flex")) }
  /// `inline-flex`.
  public var inlineFlex: Self {
    appending(TailwindStyle.DefaultTailwindClass("inline-flex"))
  }
  /// `grid`.
  public var grid: Self { appending(TailwindStyle.DefaultTailwindClass("grid")) }
  /// `block`.
  public var block: Self { appending(TailwindStyle.DefaultTailwindClass("block")) }
  /// `inline-block`.
  public var inlineBlock: Self {
    appending(TailwindStyle.DefaultTailwindClass("inline-block"))
  }
  /// `inline`.
  public var inline: Self { appending(TailwindStyle.DefaultTailwindClass("inline")) }
  /// `hidden`.
  public var hidden: Self { appending(TailwindStyle.DefaultTailwindClass("hidden")) }
  /// `container`.
  public var container: Self { appending(TailwindStyle.DefaultTailwindClass("container")) }
  /// `contents`.
  public var contents: Self { appending(TailwindStyle.DefaultTailwindClass("contents")) }
}

extension TailwindStyle: DisplayStyling {}

// Static mirrors so a display utility can start a chain with a leading dot.
extension TailwindStyle {
  /// `flex`.
  public static var flex: TailwindStyle { TailwindStyle().flex }
  /// `inline-flex`.
  public static var inlineFlex: TailwindStyle { TailwindStyle().inlineFlex }
  /// `grid`.
  public static var grid: TailwindStyle { TailwindStyle().grid }
  /// `block`.
  public static var block: TailwindStyle { TailwindStyle().block }
  /// `inline-block`.
  public static var inlineBlock: TailwindStyle { TailwindStyle().inlineBlock }
  /// `inline`.
  public static var inline: TailwindStyle { TailwindStyle().inline }
  /// `hidden`.
  public static var hidden: TailwindStyle { TailwindStyle().hidden }
  /// `container`.
  public static var container: TailwindStyle { TailwindStyle().container }
  /// `contents`.
  public static var contents: TailwindStyle { TailwindStyle().contents }
}
