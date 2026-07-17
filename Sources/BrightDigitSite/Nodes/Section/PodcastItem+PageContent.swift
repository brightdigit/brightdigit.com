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
  private var transistorIFrame: some Component {
    Node<HTML.BodyContext>.iframe(
      .attribute(named: "width", value: "100%"),
      .attribute(named: "height", value: "180"),
      .attribute(named: "frameborder", value: "no"),
      .attribute(named: "scrolling", value: "no"),
      .attribute(named: "seamless src", value: "\(transistorEmbedURL)")
    )
  }

  /// The `data-text`/`data-url` share link shown on the episodes section index —
  /// kept as a raw node to preserve exact attribute emission.
  private var sectionShareLink: some Component {
    Node<HTML.BodyContext>.a(
      .data(named: "text", value: "Episode \(episodeNo) - \(title)"),
      .data(named: "url", value: source.absoluteURL(forSite: site).absoluteString),
      .href(source.path),
      .raw("<i class=\"flaticon-share\"></i> Share")
    )
  }

  internal var featuredItemContent: Component {
    Podcast.FeaturedCard(
      episodeNo: episodeNo,
      title: title,
      description: description,
      imageURL: imageURL,
      sourcePathAbsolute: source.path.absoluteString,
      publishedDate: publishedDate,
      audioDuration: audioDuration,
      videoDuration: videoDuration,
      transistorIFrame: transistorIFrame
    )
  }

  internal var sectionItemContent: Component {
    ListItem {
      Podcast.SectionCard(
        title: title,
        description: description,
        imageURL: imageURL,
        sourcePathAbsolute: source.path.absoluteString,
        publishedDate: publishedDate,
        audioDuration: audioDuration,
        videoDuration: videoDuration,
        shareLink: sectionShareLink
      )
    }
    .id("episode-\(episodeNo)")
  }

  @ComponentBuilder internal var pageMainContent: Component {
    podcastHeader
    Main {
      descriptionHeader
      mainContent
    }
  }

  internal var podcastHeader: some Component {
    Podcast.PageHeader(
      episodeNo: episodeNo,
      title: title,
      imageURL: imageURL,
      publishedDate: publishedDate,
      audioDuration: audioDuration,
      videoDuration: videoDuration
    )
  }

  internal var descriptionHeader: some Component {
    Podcast.DescriptionHeader(
      title: title,
      description: description,
      imageURL: imageURL,
      featuredImageURL: featuredImageURL,
      transistorShareURL: transistorShareURL,
      audioDuration: audioDuration,
      videoShareLink: podcastVideoShareLink
    )
  }

  /// The YouTube share link in the media list — its `href` is conditional on
  /// `youtubeShareURL`, so it is built as a raw node to match the original
  /// `.unwrap`-based attribute emission exactly.
  private var podcastVideoShareLink: some Component {
    Node<HTML.BodyContext>.a(
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

  internal var mainContent: some Component {
    Podcast.MainContent(
      transistorEmbed: transistorEmbed,
      youtubeEmbed: youtubeEmbed,
      showNotesContent: source.body
    )
  }
}
