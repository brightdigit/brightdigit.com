//
//  FooterSocialLinks.swift
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

import Plot

/// Site-wide footer social icons.
///
/// Entries reuse `Node.li(href:flatIcon:rel:)` because their
/// `<a aria-label href rel>` attribute ordering is bespoke.
internal struct FooterSocialLinks: Component {
  internal var body: Component {
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
  }
}
