//
//  SocialPlatform.swift
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

/// A single site-wide social/contact channel.
///
/// `FooterSocialLinks` is the source of truth: every entry in ``allCases`` is
/// rendered in the site footer. Entries with a non-`nil` ``contactText`` also
/// appear on the Contact page's `#social-media` list, using that string as
/// their visible label. ``allCases`` is declared in footer render order.
internal struct SocialPlatform: CaseIterable, Sendable {
  /// The fixed set of platforms, in footer render order.
  ///
  /// A `struct` satisfies `CaseIterable` by supplying `allCases` explicitly.
  /// This is the single source of truth for both the footer and Contact lists.
  internal static let allCases: [SocialPlatform] = [
    SocialPlatform(
      href: "http://twitter.com/brightdigit",
      flatIcon: "twitter",
      contactText: "Twitter @brightdigit"
    ),
    SocialPlatform(
      href: "http://github.com/brightdigit",
      flatIcon: "github",
      contactText: "GitHub @brightdigit"
    ),
    SocialPlatform(
      href: "https://c.im/@leogdion",
      flatIcon: "mastodon",
      rel: .meRelationship
    ),
    SocialPlatform(
      href: "https://www.patreon.com/brightdigit",
      flatIcon: "patreon"
    ),
    SocialPlatform(
      href: "https://www.linkedin.com/in/leogdion/",
      flatIcon: "linkedin"
    ),
    SocialPlatform(
      href: "https://www.empowerapps.show",
      flatIcon: "podcast",
      contactText: "EmpowerApps.Show Podcast"
    ),
    SocialPlatform(
      href: "http://youtube.com/c/BrightdigitLLC",
      flatIcon: "youtube",
      contactText: "Youtube videos"
    ),
    SocialPlatform(
      href: Strings.Buttondown.archiveURL,
      flatIcon: "newsletter",
      contactText: "Our Newsletter"
    ),
    SocialPlatform(
      href: "/feed.rss",
      flatIcon: "rss",
      contactText: "Our Feed"
    ),
  ]

  internal let href: String
  internal let flatIcon: String
  internal let rel: HTMLAnchorRelationship?
  /// The Contact-page label.
  ///
  /// `nil` means the platform is footer-only.
  internal let contactText: String?

  internal init(
    href: String,
    flatIcon: String,
    rel: HTMLAnchorRelationship? = nil,
    contactText: String? = nil
  ) {
    self.href = href
    self.flatIcon = flatIcon
    self.rel = rel
    self.contactText = contactText
  }
}

extension EnvironmentKey where Value == [SocialPlatform] {
  /// The site-wide list of social platforms.
  ///
  /// Defaults to ``SocialPlatform/allCases``.
  internal static var socialPlatforms: Self {
    .init(defaultValue: SocialPlatform.allCases)
  }
}

extension Component {
  /// Override the site-wide social-platform list for this component hierarchy.
  internal func socialPlatforms(_ platforms: [SocialPlatform]) -> Component {
    environmentValue(platforms, key: .socialPlatforms)
  }
}
