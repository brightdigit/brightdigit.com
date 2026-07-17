//
//  DefaultColor.swift
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

/// The built-in Tailwind v4 color families.
///
/// A `public` type (its name is the return type of the static members below)
/// with no public initializer, so callers reference `.blue` but never
/// construct it directly — like SwiftUI's `DefaultButtonStyle`.
public struct DefaultColor: Color {
  /// `slate`.
  fileprivate static let slateValue = DefaultColor("slate")
  /// `gray`.
  fileprivate static let grayValue = DefaultColor("gray")
  /// `zinc`.
  fileprivate static let zincValue = DefaultColor("zinc")
  /// `neutral`.
  fileprivate static let neutralValue = DefaultColor("neutral")
  /// `stone`.
  fileprivate static let stoneValue = DefaultColor("stone")
  /// `red`.
  fileprivate static let redValue = DefaultColor("red")
  /// `orange`.
  fileprivate static let orangeValue = DefaultColor("orange")
  /// `amber`.
  fileprivate static let amberValue = DefaultColor("amber")
  /// `yellow`.
  fileprivate static let yellowValue = DefaultColor("yellow")
  /// `lime`.
  fileprivate static let limeValue = DefaultColor("lime")
  /// `green`.
  fileprivate static let greenValue = DefaultColor("green")
  /// `emerald`.
  fileprivate static let emeraldValue = DefaultColor("emerald")
  /// `teal`.
  fileprivate static let tealValue = DefaultColor("teal")
  /// `cyan`.
  fileprivate static let cyanValue = DefaultColor("cyan")
  /// `sky`.
  fileprivate static let skyValue = DefaultColor("sky")
  /// `blue`.
  fileprivate static let blueValue = DefaultColor("blue")
  /// `indigo`.
  fileprivate static let indigoValue = DefaultColor("indigo")
  /// `violet`.
  fileprivate static let violetValue = DefaultColor("violet")
  /// `purple`.
  fileprivate static let purpleValue = DefaultColor("purple")
  /// `fuchsia`.
  fileprivate static let fuchsiaValue = DefaultColor("fuchsia")
  /// `pink`.
  fileprivate static let pinkValue = DefaultColor("pink")
  /// `rose`.
  fileprivate static let roseValue = DefaultColor("rose")

  /// The rendered fragment, e.g. `"blue"`.
  public let token: String

  internal init(_ token: String) {
    self.token = token
  }
}

extension Color where Self == DefaultColor {
  /// `slate`.
  public static var slate: DefaultColor { .slateValue }
  /// `gray`.
  public static var gray: DefaultColor { .grayValue }
  /// `zinc`.
  public static var zinc: DefaultColor { .zincValue }
  /// `neutral`.
  public static var neutral: DefaultColor { .neutralValue }
  /// `stone`.
  public static var stone: DefaultColor { .stoneValue }
  /// `red`.
  public static var red: DefaultColor { .redValue }
  /// `orange`.
  public static var orange: DefaultColor { .orangeValue }
  /// `amber`.
  public static var amber: DefaultColor { .amberValue }
  /// `yellow`.
  public static var yellow: DefaultColor { .yellowValue }
  /// `lime`.
  public static var lime: DefaultColor { .limeValue }
  /// `green`.
  public static var green: DefaultColor { .greenValue }
  /// `emerald`.
  public static var emerald: DefaultColor { .emeraldValue }
  /// `teal`.
  public static var teal: DefaultColor { .tealValue }
  /// `cyan`.
  public static var cyan: DefaultColor { .cyanValue }
  /// `sky`.
  public static var sky: DefaultColor { .skyValue }
  /// `blue`.
  public static var blue: DefaultColor { .blueValue }
  /// `indigo`.
  public static var indigo: DefaultColor { .indigoValue }
  /// `violet`.
  public static var violet: DefaultColor { .violetValue }
  /// `purple`.
  public static var purple: DefaultColor { .purpleValue }
  /// `fuchsia`.
  public static var fuchsia: DefaultColor { .fuchsiaValue }
  /// `pink`.
  public static var pink: DefaultColor { .pinkValue }
  /// `rose`.
  public static var rose: DefaultColor { .roseValue }
}
