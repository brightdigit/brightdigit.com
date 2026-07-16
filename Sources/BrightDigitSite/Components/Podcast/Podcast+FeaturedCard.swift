//
//  Podcast+FeaturedCard.swift
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
  /// The featured podcast hero card shown on the episodes index.
  internal struct FeaturedCard: Component {
    internal let episodeNo: Int
    internal let title: String
    internal let description: String
    internal let imageURL: URL
    internal let sourcePathAbsolute: String
    internal let publishedDate: Date
    internal let audioDuration: TimeInterval
    internal let videoDuration: TimeInterval?
    internal let transistorIFrame: Node<HTML.BodyContext>

    internal var body: Component {
      Header {
        Element(name: "section") {
          Element(name: "section") {
            Header {
              Div {
                Text("episode \(episodeNo)")
              }.class("episode-no")
              Link(url: sourcePathAbsolute) {
                Image(imageURL)
                H2 { Text(title) }
              }
              Podcast.PublishDateDiv(publishedDate: publishedDate)
            }
            Main {
              Link(url: sourcePathAbsolute) {
                Image(imageURL)
              }
              Main {
                Podcast.PublishDateDiv(publishedDate: publishedDate)
                Paragraph { Text("\(description)") }
                transistorIFrame
              }
            }
            Footer {
              transistorIFrame
              Main {
                Podcast.AudioLengthDiv(audioDuration: audioDuration)
                if let videoDuration {
                  Div {
                    Icon(className: "flaticon-youtube")
                    Text(PiHTMLFactory.formatTimeInterval(videoDuration))
                  }.class("video-length")
                }
                Div {
                  Link("More Info", url: sourcePathAbsolute)
                }
              }
            }
          }.class("featured").id("episode-\(episodeNo)")
        }.class("hero")
      }
    }
  }
}
