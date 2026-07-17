//
//  PodcastItem+URLs.swift
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

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension PodcastItem {
  internal static let youtubeImageBaseURL = URL(staticString: "https://i.ytimg.com/vi/")

  internal static let maxresdefault = "maxresdefault.jpg"

  internal static let transistorShareBaseURL: URL =
    Self.transistorBaseURL.appendingPathComponent("s")
  internal static let transistorEmbedBaseURL: URL =
    Self.transistorBaseURL.appendingPathComponent("e")
  internal static let transistorBaseURL: URL =
    .init(staticString: "https://share.transistor.fm/")

  internal static let youtubeBaseURL: URL =
    .init(staticString: "https://www.youtube.com/")
  internal static let youtubeEmbedBaseURL =
    Self.youtubeBaseURL.appendingPathComponent("embed")
  internal static let youtubeShareBaseURLComponents: URLComponents = {
    guard
      let components = URLComponents(
        url: Self.youtubeBaseURL.appendingPathComponent("watch"),
        resolvingAgainstBaseURL: false
      )
    else {
      preconditionFailure("Invalid YouTube share base URL")
    }
    return components
  }()

  internal var imageURL: URL {
    guard let youtubeID = youtubeID, episodeNo > 86 else {
      return featuredImageURL
    }
    return Self.youtubeImageBaseURL.appendingPathComponent(youtubeID)
      .appendingPathComponent(Self.maxresdefault)
  }

  internal var transistorEmbedURL: URL {
    Self.transistorEmbedBaseURL.appendingPathComponent(transistorID)
  }

  internal var youtubeEmbedURL: URL? {
    youtubeID.map(Self.youtubeEmbedBaseURL.appendingPathComponent)
  }

  internal var transistorShareURL: URL {
    Self.transistorShareBaseURL.appendingPathComponent(transistorID)
  }

  internal var youtubeShareURL: URL? {
    guard let youtubeID = youtubeID else {
      return nil
    }

    var urlComponents = Self.youtubeShareBaseURLComponents
    urlComponents.queryItems = [URLQueryItem(name: "v", value: youtubeID)]
    return urlComponents.url
  }

  internal var youtubeEmbed: Component? {
    guard let youtubeEmbedURL else {
      return nil
    }
    return Node<HTML.BodyContext>.iframe(
      .src(youtubeEmbedURL),
      .frameborder(false),
      .allowfullscreen(true),
      .allow(
        // swiftlint:disable:next line_length
        "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
      )
    )
  }

  internal var transistorEmbed: some Component {
    Node<HTML.BodyContext>.iframe(
      .attribute(named: "width", value: "100%"),
      .attribute(named: "height", value: "180"),
      .frameborder(false),
      .attribute(named: "scrolling", value: "no"),
      .attribute(named: "seamless", value: nil),
      .src(transistorEmbedURL)
    )
  }
}
