import Foundation
import Plot
import Publish
import PublishType

extension Node where Context == HTML.DocumentContext {
  // swiftlint:disable:next function_body_length
  public static func head(forPage page: PageContent) -> Node {
    .head(
      .title(page.headTitle),
      .meta(name: "description", content: page.description),
      .meta(
        .charset(.utf8)
      ),
      .unwrap(
        page.redirectURL,
        { url in
          .meta(
            .attribute(named: "http-equiv", value: "refresh"),
            .attribute(named: "content", value: "0; url=\(url)")
          )
        },
        else: .meta(name: "robots", content: "index,follow")
      ),
      .meta(name: "twitter:card", content: "summary"),
      .meta(name: "twitter:site", content: "@brightdigit"),
      .meta(name: "twitter:creator", content: "@leogdion"),
      .meta(name: "twitter:title", content: page.socialTitle),
      .meta(name: "twitter:description", content: page.description),
      .meta(name: "twitter:image", content: page.socialImageURL.absoluteString),
      .meta(property: "og:url", content: page.absoluteURL.absoluteString),
      .meta(property: "og:title", content: page.socialTitle),
      .meta(property: "og:description", content: page.description),
      .meta(property: "og:image", content: page.socialImageURL.absoluteString),

      .meta(
        .name("viewport"),
        .content("width=device-width, initial-scale=1.0")
      ),

      .link(
        .rel(.alternate), .type("application/rss+xml"), .title("Main Site Content"),
        .href("/feed.rss")
      ),
      .link(
        .rel(.alternate), .type("application/rss+xml"), .title("Just Articles"),
        .href("/articles.rss")
      ),
      .link(
        .rel(.alternate), .type("application/rss+xml"), .title("Developer Tutorials"),
        .href("/tutorials.rss")
      ),
      .link(
        .rel(.alternate), .type("application/rss+xml"),
        .title("EmpowerApps.Show Podcast"),
        .href("https://feeds.transistor.fm/empowerapps-show")
      ),
      .link(
        .rel(.alternate), .type("application/rss+xml"), .title("BrightDigit Newsletter"),
        .href(
          // swiftlint:disable:next line_length
          "https://us12.campaign-archive.com/feed?u=cb3bba007ed171091f55c47f0&id=584d0d5c40"
        )
      ),

      .link(.rel(.icon), .href("/favicon.ico"), .sizes("any"), .type("image/svg+xml")),
      .link(.rel(.icon), .href("/favicon.svg"), .type("image/svg+xml")),

      .link(.rel(.manifest), .href("/site.webmanifest?v=2022")),
      .link(
        .id("mask-icon"), .rel(.maskIcon), .href("/safari-pinned-tab.svg?v=2022"),
        .color("#000000")
      ),
      .link(
        .id("apple-dark-mode-icon"), .rel(.alternate), .href("/dark-mode-mask.svg?v=2022")
      ),
      .link(
        .id("apple-light-mode-icon"), .rel(.alternate),
        .href("/safari-pinned-tab.svg?v=2022")
      ),

      .unwrap(page.canonicalURL) { canonicalURL in
        .link(.rel(.canonical), .href(canonicalURL))
      },

      .script(
        .src("/js/main.js")
      ),
      .script(
        .async(),
        .src("https://www.googletagmanager.com/gtag/js?id=G-K3MSJ0CTMJ")
      ),
      .script(
        .defer(),
        .data(named: "domain", value: "brightdigit.com"),
        .src("https://plausible.io/js/script.js")
      )
    )
  }
}
