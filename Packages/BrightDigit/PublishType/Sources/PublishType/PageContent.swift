//
//  PageContent.swift
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

import Foundation
import Plot

public protocol PageContent {
  var title: String { get }
  var description: String { get }
  var socialTitle: String { get }
  var socialImageURL: URL { get }
  var absoluteURL: URL { get }
  var main: Component { get }
  var mainClasses: [String] { get }
  var bodyID: String? { get }
  var bodyClasses: [String] { get }
  var redirectURL: URL? { get }
  var canonicalURL: URL? { get }
}

extension PageContent {
  public var mainClasses: [String] {
    []
  }

  public var mainElement: Node<HTML.BodyContext> {
    .main(
      .unwrap(mainClassValue, Node.class),
      .component(main)
    )
  }

  public var mainClassValue: String? {
    joinedClassValue(mainClasses)
  }

  public var bodyClassValue: String? {
    joinedClassValue(bodyClasses)
  }

  private func joinedClassValue(_ classes: [String]) -> String? {
    let value =
      classes
      .joined(separator: " ")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard !value.isEmpty else {
      return nil
    }

    return value
  }
}
