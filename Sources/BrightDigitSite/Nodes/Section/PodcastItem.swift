//
//  PodcastItem.swift
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

internal struct PodcastItem: SectionItem {
  internal typealias WebsiteType = BrightDigitSite

  internal static let sectionH1: String? = sectionTitle

  internal static let sectionTitle: String = "EmpowerApps Podcast"

  internal static let sectionDescription: String =
    // swiftlint:disable:next line_length
    "Watch and Listen to the latest episodes of EmpowerApps Show, we talk all things app development and Apple"

  internal let description: String
  internal let episodeNo: Int
  internal let title: String
  internal let publishedDate: Date
  internal let youtubeID: String?
  internal let audioDuration: TimeInterval
  internal let videoDuration: TimeInterval?
  internal let featuredImageURL: URL
  internal let isFeatured: Bool
  internal let transistorID: String
  internal let source: Item<BrightDigitSite>
  internal let site: WebsiteType

  internal var redirectURL: URL? {
    nil
  }

  internal var pageTitle: String {
    title
  }

  internal var pageBodyID: String? {
    nil
  }

  internal init(item: Item<BrightDigitSite>, site: BrightDigitSite) throws {
    source = item
    self.site = site
    let featuredImageURL = item.featuredImageURL
    let isFeatured = item.metadata.featured ?? false

    let episodeNo =
      item.path.absoluteString
      .components(separatedBy: "/")
      .last?
      .components(separatedBy: .decimalDigits.inverted)
      .first
      .flatMap(Int.init)

    guard let episodeNo = episodeNo else {
      throw PublishTypeError.missingField(MissingFields.PodcastField.episodeNo, item)
    }

    guard let audioDuration = item.metadata.audioDuration else {
      throw PublishTypeError.missingField(MissingFields.PodcastField.audioDuration, item)
    }

    guard let transistorID = item.metadata.podcastID else {
      throw PublishTypeError.missingField(MissingFields.PodcastField.transistorID, item)
    }

    title = item.title
    description = item.description
    self.featuredImageURL = featuredImageURL
    publishedDate = item.metadata.date
    self.episodeNo = episodeNo
    self.audioDuration = audioDuration
    videoDuration = item.metadata.videoDuration
    youtubeID = item.metadata.youtubeID
    self.isFeatured = isFeatured
    self.transistorID = transistorID
  }
}
