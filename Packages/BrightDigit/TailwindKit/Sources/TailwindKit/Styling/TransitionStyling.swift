//
//  TransitionStyling.swift
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

/// Transition utilities — the `transition-*` enabling classes plus `duration`
/// and `ease`.
///
/// A capability protocol witnessed against the ``TailwindStyleProtocol`` seam;
/// ``TailwindStyle`` conforms to it. See ``TailwindStyleProtocol`` for the
/// architecture rationale.
public protocol TransitionStyling {
  /// `transition-all`.
  var transitionAll: Self { get }
  /// `transition-opacity`.
  var transitionOpacity: Self { get }
  /// `transition-colors`.
  var transitionColors: Self { get }
  /// `transition-transform`.
  var transitionTransform: Self { get }

  /// `duration-<ms>`, e.g. `.duration(300)`.
  func duration(_ milliseconds: Int) -> Self
  /// `ease-<value>`, e.g. `.ease(.inOut)` → `ease-in-out`.
  func ease(_ ease: some Ease) -> Self
}

extension TransitionStyling where Self: TailwindStyleProtocol {
  // MARK: Transitions (bare)

  /// `transition-all`.
  public var transitionAll: Self {
    appending(TailwindStyle.DefaultTailwindClass("transition-all"))
  }
  /// `transition-opacity`.
  public var transitionOpacity: Self {
    appending(TailwindStyle.DefaultTailwindClass("transition-opacity"))
  }
  /// `transition-colors`.
  public var transitionColors: Self {
    appending(TailwindStyle.DefaultTailwindClass("transition-colors"))
  }
  /// `transition-transform`.
  public var transitionTransform: Self {
    appending(TailwindStyle.DefaultTailwindClass("transition-transform"))
  }

  // MARK: Transitions (parameterized)

  /// `duration-<ms>`, e.g. `.duration(300)`.
  public func duration(_ milliseconds: Int) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("duration-\(milliseconds)"))
  }
  /// `ease-<value>`, e.g. `.ease(.inOut)` → `ease-in-out`.
  public func ease(_ ease: some Ease) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("ease-\(ease.token)"))
  }
}

extension TailwindStyle: TransitionStyling {}

// Static mirrors so a transition utility can start a chain with a leading dot.
extension TailwindStyle {
  /// `transition-all`.
  public static var transitionAll: TailwindStyle { TailwindStyle().transitionAll }
  /// `transition-opacity`.
  public static var transitionOpacity: TailwindStyle { TailwindStyle().transitionOpacity }
  /// `transition-colors`.
  public static var transitionColors: TailwindStyle { TailwindStyle().transitionColors }
  /// `transition-transform`.
  public static var transitionTransform: TailwindStyle { TailwindStyle().transitionTransform }
}

extension TailwindStyle {
  /// `duration-<ms>`.
  public static func duration(_ milliseconds: Int) -> TailwindStyle {
    TailwindStyle().duration(milliseconds)
  }
  /// `ease-<value>`.
  public static func ease(_ ease: some Ease) -> TailwindStyle { TailwindStyle().ease(ease) }
}
