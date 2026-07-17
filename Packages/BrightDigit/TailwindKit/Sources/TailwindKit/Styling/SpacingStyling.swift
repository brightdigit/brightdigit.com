//
//  SpacingStyling.swift
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

/// The **padding** and **margin** spacing utilities.
///
/// A capability protocol whose members are witnessed against the
/// ``TailwindStyleProtocol`` seam; ``TailwindStyle`` conforms to it. See
/// ``TailwindStyleProtocol`` for why the surface is organized this way.
public protocol SpacingStyling {
  /// `p-<amount>`, e.g. `.p(.s4)`.
  func p(_ amount: DefaultSpacing) -> Self
  /// `px-<amount>`, e.g. `.px(.s4)`.
  func px(_ amount: DefaultSpacing) -> Self
  /// `py-<amount>`, e.g. `.py(.s4)`.
  func py(_ amount: DefaultSpacing) -> Self
  /// `pt-<amount>`, e.g. `.pt(.s4)`.
  func pt(_ amount: DefaultSpacing) -> Self
  /// `pr-<amount>`, e.g. `.pr(.s4)`.
  func pr(_ amount: DefaultSpacing) -> Self
  /// `pb-<amount>`, e.g. `.pb(.s4)`.
  func pb(_ amount: DefaultSpacing) -> Self
  /// `pl-<amount>`, e.g. `.pl(.s4)`.
  func pl(_ amount: DefaultSpacing) -> Self

  /// `m-<amount>`, e.g. `.m(.s4)`.
  func m(_ amount: DefaultSpacing) -> Self
  /// `mx-<amount>`, e.g. `.mx(.s4)`.
  func mx(_ amount: DefaultSpacing) -> Self
  /// `my-<amount>`, e.g. `.my(.s4)`.
  func my(_ amount: DefaultSpacing) -> Self
  /// `mt-<amount>`, e.g. `.mt(.s4)`.
  func mt(_ amount: DefaultSpacing) -> Self
  /// `mr-<amount>`, e.g. `.mr(.s4)`.
  func mr(_ amount: DefaultSpacing) -> Self
  /// `mb-<amount>`, e.g. `.mb(.s4)`.
  func mb(_ amount: DefaultSpacing) -> Self
  /// `ml-<amount>`, e.g. `.ml(.s4)`.
  func ml(_ amount: DefaultSpacing) -> Self
}

extension SpacingStyling where Self: TailwindStyleProtocol {
  // MARK: Padding

  /// `p-<amount>`, e.g. `.p(.s4)`.
  public func p(_ amount: DefaultSpacing) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("p-\(amount.token)"))
  }
  /// `px-<amount>`, e.g. `.px(.s4)`.
  public func px(_ amount: DefaultSpacing) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("px-\(amount.token)"))
  }
  /// `py-<amount>`, e.g. `.py(.s4)`.
  public func py(_ amount: DefaultSpacing) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("py-\(amount.token)"))
  }
  /// `pt-<amount>`, e.g. `.pt(.s4)`.
  public func pt(_ amount: DefaultSpacing) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("pt-\(amount.token)"))
  }
  /// `pr-<amount>`, e.g. `.pr(.s4)`.
  public func pr(_ amount: DefaultSpacing) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("pr-\(amount.token)"))
  }
  /// `pb-<amount>`, e.g. `.pb(.s4)`.
  public func pb(_ amount: DefaultSpacing) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("pb-\(amount.token)"))
  }
  /// `pl-<amount>`, e.g. `.pl(.s4)`.
  public func pl(_ amount: DefaultSpacing) -> Self {
    appending(TailwindStyle.DefaultTailwindClass("pl-\(amount.token)"))
  }

  // MARK: Margin

  /// `m-<amount>`, e.g. `.m(.s4)`.
  public func m(_ amount: DefaultSpacing) -> Self { spaced("m", amount) }
  /// `mx-<amount>`, e.g. `.mx(.s4)`.
  public func mx(_ amount: DefaultSpacing) -> Self { spaced("mx", amount) }
  /// `my-<amount>`, e.g. `.my(.s4)`.
  public func my(_ amount: DefaultSpacing) -> Self { spaced("my", amount) }
  /// `mt-<amount>`, e.g. `.mt(.s4)`.
  public func mt(_ amount: DefaultSpacing) -> Self { spaced("mt", amount) }
  /// `mr-<amount>`, e.g. `.mr(.s4)`.
  public func mr(_ amount: DefaultSpacing) -> Self { spaced("mr", amount) }
  /// `mb-<amount>`, e.g. `.mb(.s4)`.
  public func mb(_ amount: DefaultSpacing) -> Self { spaced("mb", amount) }
  /// `ml-<amount>`, e.g. `.ml(.s4)`.
  public func ml(_ amount: DefaultSpacing) -> Self { spaced("ml", amount) }

  // MARK: Helpers

  private func spaced(_ prefix: String, _ amount: DefaultSpacing) -> Self {
    amount.token.hasPrefix("-")
      ? appending(TailwindStyle.DefaultTailwindClass("-\(prefix)-\(amount.token.dropFirst())"))
      : appending(TailwindStyle.DefaultTailwindClass("\(prefix)-\(amount.token)"))
  }
}

extension TailwindStyle: SpacingStyling {}

// Static mirrors so a spacing utility can start a chain with a leading dot.
extension TailwindStyle {
  /// `p-<amount>`.
  public static func p(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().p(amount) }
  /// `px-<amount>`.
  public static func px(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().px(amount) }
  /// `py-<amount>`.
  public static func py(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().py(amount) }
  /// `pt-<amount>`.
  public static func pt(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().pt(amount) }
  /// `pr-<amount>`.
  public static func pr(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().pr(amount) }
  /// `pb-<amount>`.
  public static func pb(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().pb(amount) }
  /// `pl-<amount>`.
  public static func pl(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().pl(amount) }

  /// `m-<amount>`.
  public static func m(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().m(amount) }
  /// `mx-<amount>`.
  public static func mx(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().mx(amount) }
  /// `my-<amount>`.
  public static func my(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().my(amount) }
  /// `mt-<amount>`.
  public static func mt(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().mt(amount) }
  /// `mr-<amount>`.
  public static func mr(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().mr(amount) }
  /// `mb-<amount>`.
  public static func mb(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().mb(amount) }
  /// `ml-<amount>`.
  public static func ml(_ amount: DefaultSpacing) -> TailwindStyle { TailwindStyle().ml(amount) }
}
