//
//  Podcast+PageHeader.swift
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

extension Podcast {
  /// The podcast episode page header (episode meta list, title, hero image).
  internal struct PageHeader: Component {
    internal let episodeNo: Int
    internal let title: String
    internal let imageURL: URL
    internal let publishedDate: Date
    internal let audioDuration: TimeInterval
    internal let videoDuration: TimeInterval?

    internal var body: Component {
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
      }
    }
  }
}
