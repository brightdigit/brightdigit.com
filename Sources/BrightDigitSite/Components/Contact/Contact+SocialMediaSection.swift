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
  ///
  /// Rendered from the site-wide `SocialPlatform` list (see ``SocialPlatform``);
  /// only platforms with a `contactText` label appear here.
  internal struct SocialMediaSection: Component {
    @EnvironmentValue(.socialPlatforms) private var platforms

    internal var body: Component {
      Element(name: "section") {
        Main {
          Header {
            Image(url: "/media/social-media.svg", description: "We are on Social Media")
          }
          Main {
            Paragraph { Text("There are other ways to get a hold of us too.") }
            List(platforms) { platform in
              ComponentGroup {
                // Footer-only platforms have no label, so they render nothing here.
                if let text = platform.contactText {
                  Contact.SocialIconItem(
                    text: text, href: platform.href, flatIcon: platform.flatIcon
                  )
                }
              }
            }
            .listStyle(.ordered)
            .class("social")
          }
        }
      }.id("social-media")
    }
  }
}
