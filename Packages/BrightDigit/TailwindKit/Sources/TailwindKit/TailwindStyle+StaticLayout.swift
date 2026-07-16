//
//  TailwindStyle+StaticLayout.swift
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
  // MARK: Sizing

  /// `container`.
  public static var container: TailwindStyle { TailwindStyle().container }
  /// `contents`.
  public static var contents: TailwindStyle { TailwindStyle().contents }

  // MARK: Flexbox & grid

  /// `grow-0`.
  public static var grow0: TailwindStyle { TailwindStyle().grow0 }
  /// `shrink-0`.
  public static var shrink0: TailwindStyle { TailwindStyle().shrink0 }

  // MARK: Borders

  /// `border-none`.
  public static var borderNone: TailwindStyle { TailwindStyle().borderNone }

  // MARK: Typography

  /// `no-underline`.
  public static var noUnderline: TailwindStyle { TailwindStyle().noUnderline }
  /// `whitespace-pre-wrap`.
  public static var whitespacePreWrap: TailwindStyle { TailwindStyle().whitespacePreWrap }
  /// `leading-none`.
  public static var leadingNone: TailwindStyle { TailwindStyle().leadingNone }

  // MARK: Filters

  /// `invert`.
  public static var invert: TailwindStyle { TailwindStyle().invert }
  /// `grayscale`.
  public static var grayscale: TailwindStyle { TailwindStyle().grayscale }
  /// `backdrop-grayscale`.
  public static var backdropGrayscale: TailwindStyle { TailwindStyle().backdropGrayscale }

  // MARK: Transitions

  /// `transition-all`.
  public static var transitionAll: TailwindStyle { TailwindStyle().transitionAll }
  /// `transition-opacity`.
  public static var transitionOpacity: TailwindStyle { TailwindStyle().transitionOpacity }
  /// `transition-colors`.
  public static var transitionColors: TailwindStyle { TailwindStyle().transitionColors }
  /// `transition-transform`.
  public static var transitionTransform: TailwindStyle { TailwindStyle().transitionTransform }
}
