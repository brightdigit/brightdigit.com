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
/// Driven by the site-wide `SocialPlatform` list (see ``SocialPlatform``).
/// Each entry reuses `Node.li(href:flatIcon:rel:)` because its
/// `<a aria-label href rel>` attribute ordering is bespoke.
internal struct FooterSocialLinks: Component {
  @EnvironmentValue(.socialPlatforms) private var platforms

  internal var body: Component {
    List(platforms) { platform in
      Node.li(
        href: platform.href, flatIcon: platform.flatIcon, rel: platform.rel
      )
    }
    .listStyle(.ordered)
    .class("social")
  }
}
