//
//  IndexArticle.swift
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
import Publish

public protocol IndexArticle {
  var title: String { get }
  var tags: [Tag] { get }
  var description: String { get }
  var publishedAt: Date { get }
  var lengthInMinutes: Int { get }
  var featuredImageURL: URL { get }
  var rootRelativeURL: URL { get }
  var isAvailable: Bool { get }
}

extension Item: IndexArticle where Site == BrightDigitSite {
  public var publishedAt: Date {
    metadata.date
  }

  public var lengthInMinutes: Int {
    if let mediaDuration = metadata.videoDuration ?? metadata.audioDuration,
      sectionID == .episodes
    {
      return Int(mediaDuration / 60.0)
    }
    return readingTime.minutes
  }

  public var featuredImageURL: URL {
    URL(staticString: metadata.featuredImage)
  }

  public var isAvailable: Bool {
    self.sectionID.isIndexable
  }
}
