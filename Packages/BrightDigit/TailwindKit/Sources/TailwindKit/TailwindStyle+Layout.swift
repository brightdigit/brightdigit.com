//
//  TailwindStyle+Layout.swift
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
  // MARK: Sizing (bare)

  /// `container`.
  public var container: TailwindStyle { appending("container") }
  /// `contents`.
  public var contents: TailwindStyle { appending("contents") }

  // MARK: Flexbox & grid (bare)

  /// `grow-0`.
  public var grow0: TailwindStyle { appending("grow-0") }
  /// `shrink-0`.
  public var shrink0: TailwindStyle { appending("shrink-0") }

  // MARK: Borders (bare)

  /// `border-none` (`border-style: none`).
  public var borderNone: TailwindStyle { appending("border-none") }

  // MARK: Typography (bare)

  /// `no-underline`.
  public var noUnderline: TailwindStyle { appending("no-underline") }
  /// `whitespace-pre-wrap`.
  public var whitespacePreWrap: TailwindStyle { appending("whitespace-pre-wrap") }
}

// Parameterized layout utilities.
extension TailwindStyle {
  // MARK: Positioning, flex & list sets

  /// `position`, e.g. `.position(.relative)` → `relative`.
  public func position(_ value: Position) -> TailwindStyle {
    appending(value.token)
  }
  /// `flex-<value>` shorthand, e.g. `.flex(.one)` → `flex-1`,
  /// `.flex(.none)` → `flex-none`.
  public func flex(_ value: Flex) -> TailwindStyle {
    appending("flex-\(value.token)")
  }
  /// `flex-<direction>`, e.g. `.flexDirection(.col)` → `flex-col`,
  /// `.flexDirection(.rowReverse)` → `flex-row-reverse`.
  public func flexDirection(_ value: FlexDirection) -> TailwindStyle {
    appending("flex-\(value.token)")
  }
  /// `list-<value>`, e.g. `.list(.disc)` → `list-disc`,
  /// `.list(.inside)` → `list-inside`.
  public func list(_ value: ListStyle) -> TailwindStyle {
    appending("list-\(value.token)")
  }

  // MARK: Position offsets & z-index

  /// `top-<n>`.
  public func top(_ amount: Spacing) -> TailwindStyle { appending("top-\(amount.token)") }
  /// `right-<n>`.
  public func right(_ amount: Spacing) -> TailwindStyle { appending("right-\(amount.token)") }
  /// `bottom-<n>`.
  public func bottom(_ amount: Spacing) -> TailwindStyle { appending("bottom-\(amount.token)") }
  /// `left-<n>`.
  public func left(_ amount: Spacing) -> TailwindStyle { appending("left-\(amount.token)") }
  /// `inset-<n>`.
  public func inset(_ amount: Spacing) -> TailwindStyle { appending("inset-\(amount.token)") }
  /// `z-<n>`, e.g. `.z(50)`.
  public func z(_ index: Int) -> TailwindStyle { appending("z-\(index)") }

  // MARK: Sizing extras

  /// `max-w-<size>`, e.g. `.maxW(.xl4)` or `.maxW(.arbitrary("48rem"))`.
  public func maxW(_ size: MaxWidth) -> TailwindStyle { appending("max-w-\(size.token)") }
  /// `max-h-<size>`, e.g. `.maxH(.full)` or `.maxH(60)`.
  public func maxH(_ size: Size) -> TailwindStyle { appending("max-h-\(size.token)") }

  // MARK: Flex / grid alignment extras

  /// `self-<align>`, e.g. `.selfAlign(.start)` → `self-start`.
  public func selfAlign(_ align: Align) -> TailwindStyle {
    appending("self-\(align.token)")
  }
  /// `justify-items-<value>`, e.g. `.justifyItems(.end)`.
  public func justifyItems(_ align: Align) -> TailwindStyle {
    appending("justify-items-\(align.token)")
  }
  /// `justify-self-<value>`, e.g. `.justifySelf(.center)`.
  public func justifySelf(_ align: Align) -> TailwindStyle {
    appending("justify-self-\(align.token)")
  }
  /// `content-<value>`, e.g. `.content(.between)` → `content-between`.
  public func content(_ value: Justify) -> TailwindStyle {
    appending("content-\(value.token)")
  }
  /// `place-items-<align>`, e.g. `.placeItems(.stretch)`.
  public func placeItems(_ align: Align) -> TailwindStyle {
    appending("place-items-\(align.token)")
  }
  /// `place-self-<align>`, e.g. `.placeSelf(.center)`.
  public func placeSelf(_ align: Align) -> TailwindStyle {
    appending("place-self-\(align.token)")
  }
  /// `space-x-<n>`, e.g. `.spaceX(1)`.
  public func spaceX(_ amount: Spacing) -> TailwindStyle {
    appending("space-x-\(amount.token)")
  }
  /// `space-y-<n>`.
  public func spaceY(_ amount: Spacing) -> TailwindStyle {
    appending("space-y-\(amount.token)")
  }

  // MARK: Borders extras

  /// `border-<side>-<n>`, e.g. `.border(.top, 2)` → `border-t-2`.
  public func border(_ side: BorderSide, _ width: Int) -> TailwindStyle {
    appending("border-\(side.token)-\(width)")
  }

  // MARK: Typography extras

  /// `align-<value>`, e.g. `.align(.middle)` → `align-middle`.
  public func align(_ value: VerticalAlign) -> TailwindStyle {
    appending("align-\(value.token)")
  }
  /// `tracking-<value>`, e.g. `.tracking(.tight)`.
  public func tracking(_ value: Tracking) -> TailwindStyle {
    appending("tracking-\(value.token)")
  }
}
