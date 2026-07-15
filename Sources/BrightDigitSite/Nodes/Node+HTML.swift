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
  // MARK: - HeaderNav

  // Add an `<li>` HTML element within the current context.
  // - parameter nodes: The element's attributes and child elements.
  // swiftlint:disable:next function_body_length
  public static func header() -> Node {
    .header(
      .nav(
        .ol(
          .class("logo"),
          .li(
            .a(
              .href("/"),
              .img(.src("/media/brightdigit-name.svg"), .alt("BrightDigit"))
            )
          )
        ),
        .ol(
          .class("menu"),
          .li(for: "Services"),
          .li(for: "Products"),
          .li(for: "Articles"),
          .li(for: "Tutorials")
        ),
        .ol(
          .class("menu"),
          .li(for: "Podcast", at: "episodes"),
          .li(for: "Newsletters"),
          .li(
            .a(
              .href("https://www.patreon.com/brightdigit"),
              .text("Sponsorship")
            )
          ),
          .li(
            .a(
              .href("/about-us"),
              .text("About")
            )
          )
        ),
        .ol(
          .class("menu"),
          .li(
            .a(
              .href("/contact-us"),
              .text("Contact Us")
            )
          )
        ),
        .ol(
          .class("more"),
          .li(
            .button(
              .id("menu"),
              .img(
                .src("/media/list.svg"),
                .alt("Mobile Menu")
              )
            )
          )
        )
      )
    )
  }
}

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

// MARK: - makeFooter

extension Node where Context == HTML.BodyContext {
  // swiftlint:disable:next function_body_length
  public static func footer() -> Node {
    .footer(
      .footer(
        .header(
          .a(
            .href("/"),
            .img(
              .class("logo"),
              .alt("BrightDigit"),
              .src("/media/brightdigit-name.svg")
            )
          )
        ),
        .ol(
          .class("social"),
          .li(href: "http://twitter.com/brightdigit", flatIcon: "twitter"),
          .li(href: "http://github.com/brightdigit", flatIcon: "github"),
          .li(href: "https://c.im/@leogdion", flatIcon: "mastodon", rel: .meRelationship),
          .li(href: "https://www.patreon.com/brightdigit", flatIcon: "patreon"),
          .li(href: "https://www.linkedin.com/in/leogdion/", flatIcon: "linkedin"),
          .li(href: "https://www.empowerapps.show", flatIcon: "podcast"),
          .li(href: "http://youtube.com/c/BrightdigitLLC", flatIcon: "youtube"),
          .li(
            href: Strings.Buttondown.archiveURL,
            flatIcon: "newsletter"
          ),
          .li(href: "/feed.rss", flatIcon: "rss")
        ),
        .footer(
          .div(
            .class("address"),
            .text("503 Mall Court #150 Lansing MI 48912")
          ),
          .div(
            .class("copyright"),
            .text("© Bright Digit, LLC "),
            .year()
          )
        )
      )
    )
  }
}

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
