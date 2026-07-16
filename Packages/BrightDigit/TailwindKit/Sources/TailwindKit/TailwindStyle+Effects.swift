//
//  TailwindStyle+Effects.swift
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
  // MARK: Filters (bare)

  /// `invert` (`invert(100%)`).
  ///
  /// Note: v4 removed the bare `filter`/`backdrop-filter` enabling classes
  /// (filters auto-compose), so they are intentionally not modeled.
  public var invert: TailwindStyle { appending("invert") }
  /// `grayscale` (`grayscale(100%)`).
  public var grayscale: TailwindStyle { appending("grayscale") }
  /// `backdrop-grayscale` (`grayscale(100%)`).
  public var backdropGrayscale: TailwindStyle { appending("backdrop-grayscale") }

  // MARK: Transitions (bare)

  /// `transition-all`.
  public var transitionAll: TailwindStyle { appending("transition-all") }
  /// `transition-opacity`.
  public var transitionOpacity: TailwindStyle { appending("transition-opacity") }
  /// `transition-colors`.
  public var transitionColors: TailwindStyle { appending("transition-colors") }
  /// `transition-transform`.
  public var transitionTransform: TailwindStyle { appending("transition-transform") }

  // MARK: Typography (bare)

  /// `leading-none` (`line-height: 1`).
  ///
  /// v4 dropped the named `leading-{tight,snug,normal,relaxed,loose}` classes;
  /// only `leading-none` and numeric `leading-<n>` remain documented.
  public var leadingNone: TailwindStyle { appending("leading-none") }
}

// Parameterized effect/filter utilities.
extension TailwindStyle {
  // MARK: Effects

  /// `shadow-<value>`, e.g. `.shadow(.lg)`.
  public func shadow(_ shadow: some Shadow) -> TailwindStyle {
    appending("shadow-\(shadow.token)")
  }
  /// `drop-shadow-<value>`, e.g. `.dropShadow(.xl)`.
  public func dropShadow(_ shadow: some DropShadow) -> TailwindStyle {
    appending("drop-shadow-\(shadow.token)")
  }
  /// `ring-<n>`, e.g. `.ring(4)`.
  public func ring(_ width: Int) -> TailwindStyle { appending("ring-\(width)") }
  /// `opacity-<n>`, e.g. `.opacity(90)`.
  public func opacity(_ value: Int) -> TailwindStyle { appending("opacity-\(value)") }

  // MARK: Object fit

  /// `object-<fit>`, e.g. `.object(.cover)`.
  public func object(_ fit: ObjectFit) -> TailwindStyle {
    appending("object-\(fit.token)")
  }

  // MARK: Transitions

  /// `duration-<ms>`, e.g. `.duration(300)`.
  public func duration(_ milliseconds: Int) -> TailwindStyle {
    appending("duration-\(milliseconds)")
  }
  /// `ease-<value>`, e.g. `.ease(.inOut)` → `ease-in-out`.
  public func ease(_ ease: some Ease) -> TailwindStyle { appending("ease-\(ease.token)") }

  // MARK: Filters (parameterized)

  /// `backdrop-blur-<size>`, e.g. `.backdropBlur(.lg)`.
  public func backdropBlur(_ radius: some Radius) -> TailwindStyle {
    radius.token.isEmpty
      ? appending("backdrop-blur")
      : appending("backdrop-blur-\(radius.token)")
  }
  /// `backdrop-brightness-<n>`, e.g. `.backdropBrightness(50)`.
  public func backdropBrightness(_ value: Int) -> TailwindStyle {
    appending("backdrop-brightness-\(value)")
  }
  /// `hue-rotate-<deg>`, e.g. `.hueRotate(180)`.
  public func hueRotate(_ degrees: Int) -> TailwindStyle {
    appending("hue-rotate-\(degrees)")
  }

  // MARK: Line height

  /// `leading-<n>` (numeric line-height), e.g. `.leading(6)`.
  public func leading(_ value: Int) -> TailwindStyle { appending("leading-\(value)") }
}
