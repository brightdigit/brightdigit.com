//
//  Podcast+SectionCard.swift
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
  /// A podcast episode row on the episodes section index.
  internal struct SectionCard: Component {
    internal let title: String
    internal let description: String
    internal let imageURL: URL
    internal let sourcePathAbsolute: String
    internal let publishedDate: Date
    internal let audioDuration: TimeInterval
    internal let videoDuration: TimeInterval?
    internal let shareLink: Node<HTML.BodyContext>

    internal var body: Component {
      ComponentGroup {
        Header {
          Link(url: sourcePathAbsolute) {
            Image(imageURL)
            H2 { Text(title) }
          }
          Podcast.PublishDateDiv(publishedDate: publishedDate)
        }
        Main { Text(description) }
        Footer {
          Podcast.AudioLengthDiv(audioDuration: audioDuration)
          Div {
            Icon(className: "flaticon-youtube")
            if let videoDuration {
              Text(PiHTMLFactory.formatTimeInterval(videoDuration))
            }
          }.class("video-length")
          Div {
            shareLink
          }
        }
      }
    }
  }
}
