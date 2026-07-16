//
//  TailwindStyle+ColorOpacity.swift
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
  /// `bg-white/<opacity>`, e.g. `.bgWhite(opacity: 90)` → `bg-white/90`.
  public func bgWhite(opacity: Int) -> TailwindStyle {
    appending("bg-white/\(opacity)")
  }
  /// `bg-black/<opacity>`, e.g. `.bgBlack(opacity: 30)` → `bg-black/30`.
  public func bgBlack(opacity: Int) -> TailwindStyle {
    appending("bg-black/\(opacity)")
  }
  /// `bg-<color>-<shade>/<opacity>`, e.g. `.bg(.gray, .s500, opacity: 50)`.
  public func bg(_ color: some Color, _ shade: Shade, opacity: Int) -> TailwindStyle {
    appending("bg-\(color.token)-\(shade.token)/\(opacity)")
  }
  /// `text-<color>-<shade>/<opacity>`.
  public func text(_ color: some Color, _ shade: Shade, opacity: Int) -> TailwindStyle {
    appending("text-\(color.token)-\(shade.token)/\(opacity)")
  }
  /// `border-<color>-<shade>/<opacity>`, e.g. `.borderColor(.gray, .s400, opacity: 10)`.
  public func borderColor(_ color: some Color, _ shade: Shade, opacity: Int) -> TailwindStyle {
    appending("border-\(color.token)-\(shade.token)/\(opacity)")
  }
}

// Static mirrors so opacity-modified color chains can start with a leading dot.
extension TailwindStyle {
  /// `bg-white/<opacity>`.
  public static func bgWhite(opacity: Int) -> TailwindStyle {
    TailwindStyle().bgWhite(opacity: opacity)
  }
  /// `bg-black/<opacity>`.
  public static func bgBlack(opacity: Int) -> TailwindStyle {
    TailwindStyle().bgBlack(opacity: opacity)
  }
  /// `bg-<color>-<shade>/<opacity>`.
  public static func bg(_ color: some Color, _ shade: Shade, opacity: Int) -> TailwindStyle {
    TailwindStyle().bg(color, shade, opacity: opacity)
  }
  /// `text-<color>-<shade>/<opacity>`.
  public static func text(_ color: some Color, _ shade: Shade, opacity: Int) -> TailwindStyle {
    TailwindStyle().text(color, shade, opacity: opacity)
  }
  /// `border-<color>-<shade>/<opacity>`.
  public static func borderColor(_ color: some Color, _ shade: Shade, opacity: Int)
    -> TailwindStyle
  {
    TailwindStyle().borderColor(color, shade, opacity: opacity)
  }
}
