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
  /// The Transistor audio player iframe (bespoke `seamless src` attribute — kept
  /// as a raw node to preserve exact attribute emission).
  private var transistorIFrame: Node<HTML.BodyContext> {
    .iframe(
      .attribute(named: "width", value: "100%"),
      .attribute(named: "height", value: "180"),
      .attribute(named: "frameborder", value: "no"),
      .attribute(named: "scrolling", value: "no"),
      .attribute(named: "seamless src", value: "\(transistorEmbedURL)")
    )
  }

  private var publishDateDiv: Component {
    Div {
      Text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
    }.class("publish-date")
  }

  private var audioLengthDiv: Component {
    Div {
      Icon(className: "flaticon-podcast")
      Text(PiHTMLFactory.formatTimeInterval(audioDuration))
    }.class("audio-length")
  }

  internal var featuredItemContent: Node<HTML.BodyContext> {
    Header {
      Element(name: "section") {
        Element(name: "section") {
          Header {
            Div {
              Text("episode \(episodeNo)")
            }.class("episode-no")
            Link(url: source.path.absoluteString) {
              Image(imageURL)
              H2 { Text(title) }
            }
            publishDateDiv
          }
          Main {
            Link(url: source.path.absoluteString) {
              Image(imageURL)
            }
            Main {
              publishDateDiv
              Paragraph { Text("\(description)") }
              transistorIFrame
            }
          }
          Footer {
            transistorIFrame
            Main {
              audioLengthDiv
              if let videoDuration {
                Div {
                  Icon(className: "flaticon-youtube")
                  Text(PiHTMLFactory.formatTimeInterval(videoDuration))
                }.class("video-length")
              }
              Div {
                Link("More Info", url: source.path.absoluteString)
              }
            }
          }
        }.class("featured").id("episode-\(episodeNo)")
      }.class("hero")
    }.convertToNode()
  }

  internal var sectionItemContent: [Node<HTML.BodyContext>] {
    [
      .id("episode-\(episodeNo)"),
      Header {
        Link(url: source.path.absoluteString) {
          Image(imageURL)
          H2 { Text(title) }
        }
        publishDateDiv
      }.convertToNode(),
      Main { Text(description) }.convertToNode(),
      Footer {
        audioLengthDiv
        Div {
          Icon(className: "flaticon-youtube")
          if let videoDuration {
            Text(PiHTMLFactory.formatTimeInterval(videoDuration))
          }
        }.class("video-length")
        Div {
          // `data-text`/`data-url` + raw share icon — keep the exact node.
          Node<HTML.BodyContext>.a(
            .data(named: "text", value: "Episode \(episodeNo) - \(title)"),
            .data(named: "url", value: source.absoluteURL(forSite: site).absoluteString),
            .href(source.path),
            .raw("<i class=\"flaticon-share\"></i> Share")
          )
        }
      }.convertToNode(),
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
    Header {
      Element(name: "ol") {
        ListItem {
          Icon(className: "flaticon-announcement")
          Text("Episode #\(episodeNo)")
        }.class("episode-no")
        ListItem {
          Icon(className: "flaticon-calendar")
          Text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
        }.class("publish-date")
        ListItem {
          Icon(className: "flaticon-podcast")
          Text(PiHTMLFactory.formatTimeInterval(audioDuration))
        }.class("audio-length")
        ListItem {
          Icon(className: "flaticon-youtube")
          if let videoDuration {
            Text(PiHTMLFactory.formatTimeInterval(videoDuration))
          }
        }.class("video-length")
      }
      H1 { Text("\(title)") }
      // `class` precedes `src` in the original markup; Image emits src first, so
      // use a raw img node to preserve attribute order.
      Node<HTML.BodyContext>.img(.class("default"), .src(imageURL))
    }.convertToNode()
  }

  internal var descriptionHeader: Node<HTML.BodyContext> {
    Header {
      Node<HTML.BodyContext>.img(.class("youtube"), .src(imageURL))
      H1 { Text("\(title)") }
      Main {
        Node<HTML.BodyContext>.img(.class("album"), .src(featuredImageURL))
        Div {
          Text(description)
        }.class("description")
      }
      Element(name: "ol") {
        ListItem {
          Link(url: transistorShareURL) {
            Element(name: "i") {
              Text(PiHTMLFactory.formatTimeInterval(audioDuration))
            }.class("flaticon-podcast")
            Span {
              Text(" podcast ")
              Span {
                Text("at transistor.fm")
              }.class("source")
            }.class("specs")
          }
        }
        ListItem {
          podcastVideoShareLink
        }
      }.class("media")
    }.convertToNode()
  }

  /// The YouTube share link in the media list — its `href` is conditional on
  /// `youtubeShareURL`, so it is built as a raw node to match the original
  /// `.unwrap`-based attribute emission exactly.
  private var podcastVideoShareLink: Node<HTML.BodyContext> {
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
  }

  internal var mainContent: Node<HTML.BodyContext> {
    Main {
      Div {
        transistorEmbed
        if let youtubeEmbed {
          youtubeEmbed
        }
      }.class("content")
      showNotes
    }.convertToNode()
  }

  internal var showNotes: Node<HTML.BodyContext> {
    Main {
      Node<HTML.BodyContext>.contentBody(source.body)
    }.class("show-notes").convertToNode()
  }
}
