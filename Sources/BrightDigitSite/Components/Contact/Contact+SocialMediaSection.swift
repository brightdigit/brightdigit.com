//
//  Contact+SocialMediaSection.swift
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

extension Contact {
  /// `#social-media` alternate contact channels section.
  internal struct SocialMediaSection: Component {
    internal var body: Component {
      Element(name: "section") {
        Main {
          Header {
            Image(url: "/media/social-media.svg", description: "We are on Social Media")
          }
          Main {
            Paragraph { Text("There are other ways to get a hold of us too.") }
            Element(name: "ol") {
              Contact.SocialIconItem(
                text: "Twitter @brightdigit", href: "/", flatIcon: "twitter"
              )
              Contact.SocialIconItem(
                text: "GitHub @brightdigit", href: "/", flatIcon: "github"
              )
              Contact.SocialIconItem(
                text: "EmpowerApps.Show Podcast", href: "/", flatIcon: "podcast"
              )
              Contact.SocialIconItem(
                text: "Youtube videos", href: "/", flatIcon: "youtube"
              )
              Contact.SocialIconItem(
                text: "Our Newsletter", href: "/", flatIcon: "newletter"
              )
              Contact.SocialIconItem(
                text: "Our Feed", href: "/", flatIcon: "rss"
              )
            }.class("social")
          }
        }
      }.id("social-media")
    }
  }
}
