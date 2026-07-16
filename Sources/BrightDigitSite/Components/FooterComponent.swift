//
//  FooterComponent.swift
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

/// The site-wide footer: logo, social links, address, and copyright.
///
/// Renders the same markup as the former `Node.footer()` factory, expressed with
/// Plot's component API. Social entries reuse the `Node.li(href:flatIcon:rel:)`
/// helper because their `<a aria-label href rel>` attribute ordering is bespoke
/// and must be preserved.
internal struct FooterComponent: Component {
  internal var body: Component {
    Footer {
      Footer {
        Header {
          // `class alt src` attribute ordering is bespoke; keep the exact node.
          Node<HTML.BodyContext>.a(
            .href("/"),
            .img(
              .class("logo"),
              .alt("BrightDigit"),
              .src("/media/brightdigit-name.svg")
            )
          )
        }
        Element(name: "ol") {
          Node<HTML.ListContext>.li(
            href: "http://twitter.com/brightdigit", flatIcon: "twitter"
          )
          Node<HTML.ListContext>.li(
            href: "http://github.com/brightdigit", flatIcon: "github"
          )
          Node<HTML.ListContext>.li(
            href: "https://c.im/@leogdion", flatIcon: "mastodon", rel: .meRelationship
          )
          Node<HTML.ListContext>.li(
            href: "https://www.patreon.com/brightdigit", flatIcon: "patreon"
          )
          Node<HTML.ListContext>.li(
            href: "https://www.linkedin.com/in/leogdion/", flatIcon: "linkedin"
          )
          Node<HTML.ListContext>.li(
            href: "https://www.empowerapps.show", flatIcon: "podcast"
          )
          Node<HTML.ListContext>.li(
            href: "http://youtube.com/c/BrightdigitLLC", flatIcon: "youtube"
          )
          Node<HTML.ListContext>.li(
            href: Strings.Buttondown.archiveURL, flatIcon: "newsletter"
          )
          Node<HTML.ListContext>.li(href: "/feed.rss", flatIcon: "rss")
        }.class("social")
        Footer {
          Div {
            Text("503 Mall Court #150 Lansing MI 48912")
          }.class("address")
          Div {
            Text("© Bright Digit, LLC ")
            Node<HTML.BodyContext>.year()
          }.class("copyright")
        }
      }
    }
  }
}
