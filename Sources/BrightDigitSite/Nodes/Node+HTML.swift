//
//  Node+HTML.swift
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
import Publish
import PublishType

extension Node where Context == HTML.ListContext {
  /// Add an `<li>` HTML element within the current context.
  /// - parameter nodes: The element's attributes and child elements.
  public static func li(for name: String, at path: String? = nil) -> Node {
    .li(
      .a(
        .href("/" + (path ?? name.lowercased())),
        .text(name.capitalized)
      )
    )
  }
}

// MARK: - ItemList

extension Node where Context == HTML.BodyContext {
  public static func year(fromDate date: Date = Date()) -> Self {
    text(PiHTMLFactory.yearFormatter.string(from: date))
  }
}

// MARK: - makeHead

extension Node where Context == HTML.HeadContext {
  public static func meta(name: String, content: String) -> Node<HTML.HeadContext> {
    .meta(
      .attribute(named: "name", value: name),
      .attribute(named: "content", value: content)
    )
  }

  public static func meta(property: String, content: String) -> Node<HTML.HeadContext> {
    .meta(
      .attribute(named: "property", value: property),
      .attribute(named: "content", value: content)
    )
  }
}

extension PageContent {
  public var headTitle: String {
    [title, "BrightDigit"].joined(separator: " | ")
  }
}

// MARK: - Social relationship

extension HTMLAnchorRelationship {
  public static let meRelationship: HTMLAnchorRelationship = "me"
}

extension Node where Context == HTML.ListContext {
  public static func li(
    href: String, flatIcon: String, rel: HTMLAnchorRelationship? = nil
  ) -> Node {
    .li(
      .a(
        .ariaLabel(flatIcon.capitalized),
        .href(href),
        .i(.class("flaticon-\(flatIcon)")),
        .unwrap(
          rel,
          {
            .rel($0)
          }
        )
      )
    )
  }
}
