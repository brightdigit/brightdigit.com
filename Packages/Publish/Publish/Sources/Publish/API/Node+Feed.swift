/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Plot

extension Node where Context: RSSItemContext {
  internal static func guid<T>(for item: Item<T>, site: T) -> Node {
    .guid(
      .text(item.rssProperties.guid ?? site.url(for: item).absoluteString),
      .isPermaLink(item.rssProperties.guid == nil && item.rssProperties.link == nil)
    )
  }

  internal static func content<T>(for item: Item<T>, site: T) -> Node {
    let baseURL = site.url
    let prefixes = (href: "href=\"", src: "src=\"")

    var html = item.rssProperties.bodyPrefix ?? ""
    html.append(item.body.html)
    html.append(item.rssProperties.bodySuffix ?? "")

    var links = [(url: URL, range: Range<String.Index>, isHref: Bool)]()

    // Rewrite root-relative `href=`/`src=` attribute values to absolute URLs.
    // Each match spans the full `href="…"`/`src="…"` so it can be replaced
    // wholesale; only values that begin with "/" are rewritten.
    // The pattern is a compile-time constant known to be a valid expression.
    // swift-format-ignore: NeverUseForceTry
    // swiftlint:disable:next force_try
    let regex = try! NSRegularExpression(pattern: "(href|src)=\"([^\"]*)\"")
    let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)

    for match in regex.matches(in: html, range: fullRange) {
      guard let matchRange = Range(match.range, in: html),
        let attributeRange = Range(match.range(at: 1), in: html),
        let valueRange = Range(match.range(at: 2), in: html)
      else {
        continue
      }

      let url = html[valueRange]

      // Only rewrite root-relative values. Resolve via `URL(string:relativeTo:)`
      // so a leading `/` is treated as a path from the host root — not as a
      // path component that `appendingPathComponent` may mishandle across
      // Foundation versions.
      guard url.first == "/",
        let absoluteURL = URL(string: String(url), relativeTo: baseURL)?.absoluteURL
      else {
        continue
      }

      let isHref = (html[attributeRange] == "href")
      links.append((absoluteURL, matchRange, isHref))
    }

    for (url, range, isHref) in links.reversed() {
      let prefix = isHref ? prefixes.href : prefixes.src
      html.replaceSubrange(range, with: prefix + url.absoluteString + "\"")
    }

    return content(html)
  }
}

extension Node where Context == PodcastFeed.ItemContext {
  internal static func duration(_ duration: Audio.Duration) -> Node {
    .duration(
      hours: duration.hours,
      minutes: duration.minutes,
      seconds: duration.seconds
    )
  }
}
