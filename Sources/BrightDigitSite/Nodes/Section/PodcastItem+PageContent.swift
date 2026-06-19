//
//  PodcastItem+PageContent.swift
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

extension PodcastItem {
  internal var featuredItemContent: Node<HTML.BodyContext> {
    .header(
      .section(
        .class("hero"),
        .section(
          .class("featured"),
          .id("episode-\(episodeNo)"),
          .header(
            .div(
              .class("episode-no"),
              .text("episode \(episodeNo)")
            ),
            .a(
              .href(source.path),
              .img(.src(imageURL)),
              .h2(.text(title))
            ),
            .div(
              .class("publish-date"),
              .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
            )
          ),
          .main(
            .a(
              .href(source.path),
              .img(.src(imageURL))
            ),
            .main(
              .div(
                .class("publish-date"),
                .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
              ),
              .p("\(description)"),
              .iframe(
                .attribute(named: "width", value: "100%"),
                .attribute(named: "height", value: "180"),
                .attribute(named: "frameborder", value: "no"),
                .attribute(named: "scrolling", value: "no"),
                .attribute(named: "seamless src", value: "\(transistorEmbedURL)")
              )
            )
          ),
          .footer(
            .iframe(
              .attribute(named: "width", value: "100%"),
              .attribute(named: "height", value: "180"),
              .attribute(named: "frameborder", value: "no"),
              .attribute(named: "scrolling", value: "no"),
              .attribute(named: "seamless src", value: "\(transistorEmbedURL)")
            ),
            .main(
              .div(
                .class("audio-length"),
                .i(.class("flaticon-podcast")),
                .text(PiHTMLFactory.formatTimeInterval(audioDuration))
              ),
              .unwrap(videoDuration) { videoDuration in
                .div(
                  .class("video-length"),
                  .i(.class("flaticon-youtube")),
                  .text(PiHTMLFactory.formatTimeInterval(videoDuration))
                )
              },
              .div(
                .a(
                  .href(source.path),
                  .text("More Info")
                )
              )
            )
          )
        )
      )
    )
  }

  internal var sectionItemContent: [Node<HTML.BodyContext>] {
    [
      .id("episode-\(episodeNo)"),
      .header(
        .a(
          .href(source.path),
          .img(.src(imageURL)),
          .h2(.text(title))
        ),
        .div(
          .class("publish-date"),
          .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
        )
      ),
      .main(.text(description)),
      .footer(
        .div(
          .class("audio-length"),
          .i(.class("flaticon-podcast")),
          .text(PiHTMLFactory.formatTimeInterval(audioDuration))
        ),
        .div(
          .class("video-length"),
          .i(.class("flaticon-youtube")),
          .unwrap(videoDuration) { videoDuration in
            .text(PiHTMLFactory.formatTimeInterval(videoDuration))
          }
        ),
        .div(
          .a(
            .data(named: "text", value: "Episode \(episodeNo) - \(title)"),
            .data(named: "url", value: source.absoluteURL(forSite: site).absoluteString),
            .href(source.path),
            .raw("<i class=\"flaticon-share\"></i> Share")
          )
        )
      ),
    ]
  }

  internal var pageMainContent: [Node<HTML.BodyContext>] {
    [
      podcastHeader,
      .main(
        descriptionHeader,
        mainContent
      ),
    ]
  }

  internal var podcastHeader: Node<HTML.BodyContext> {
    .header(
      .ol(
        .li(
          .class("episode-no"),
          .i(.class("flaticon-announcement")),
          .text("Episode #\(episodeNo)")
        ),
        .li(
          .class("publish-date"),
          .i(.class("flaticon-calendar")),
          .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
        ),
        .li(
          .class("audio-length"),
          .i(.class("flaticon-podcast")),
          .text(PiHTMLFactory.formatTimeInterval(audioDuration))
        ),
        .li(
          .class("video-length"),
          .i(.class("flaticon-youtube")),
          .unwrap(videoDuration) { videoDuration in
            .text(PiHTMLFactory.formatTimeInterval(videoDuration))
          }
        )
      ),
      .h1("\(title)"),
      .img(
        .class("default"),
        .src(imageURL)
      )
    )
  }

  internal var descriptionHeader: Node<HTML.BodyContext> {
    .header(
      .img(
        .class("youtube"),
        .src(imageURL)
      ),
      .h1("\(title)"),
      .main(
        .img(
          .class("album"),
          .src(featuredImageURL)
        ),
        .div(
          .class("description"),
          .text(description)
        )
      ),
      .ol(
        .class("media"),
        .li(
          .a(
            .href(transistorShareURL),
            .i(
              .class("flaticon-podcast"),
              .text(PiHTMLFactory.formatTimeInterval(audioDuration))
            ),
            .span(
              .class("specs"),
              .text(" podcast "),
              .span(
                .class("source"),
                .text("at transistor.fm")
              )
            )
          )
        ),
        .li(
          .a(
            .unwrap(youtubeShareURL) { youtubeShareURL in
              .href(youtubeShareURL)
            },
            .i(.class("flaticon-youtube")),
            .unwrap(videoDuration) { videoDuration in
              .text(PiHTMLFactory.formatTimeInterval(videoDuration))
            },
            .span(
              .class("specs"),
              .text(" video "),
              .span(
                .class("source"),
                .text("at youtube.com")
              )
            )
          )
        )
      )
    )
  }

  internal var mainContent: Node<HTML.BodyContext> {
    .main(
      .div(
        .class("content"),
        transistorEmbed,
        .unwrap(youtubeEmbed) { $0 }
      ),
      showNotes
    )
  }

  internal var showNotes: Node<HTML.BodyContext> {
    .main(
      .class("show-notes"),
      .contentBody(source.body)
    )
  }
}
