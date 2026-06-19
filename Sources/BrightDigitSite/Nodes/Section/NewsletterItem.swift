//
//  NewsletterItem.swift
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

internal struct NewsletterItem: SectionItem {
  internal typealias WebsiteType = BrightDigitSite

  internal static let sectionH1: String? = nil
  internal static let sectionTitle: String = "Newsletters"
  internal static let sectionDescription: String =
    // swiftlint:disable:next line_length
    "Subscribe to the BrightDigit newsletter now and get  helpful tips and advice right to your inbox!"

  internal let description: String
  internal let issueNo: Int
  internal let featuredImageURL: URL
  internal let archiveURL: URL
  internal let title: String
  internal let publishedDate: Date
  internal let source: Item<BrightDigitSite>

  internal let isFeatured: Bool

  internal var pageTitle: String {
    title
  }

  internal var pageBodyID: String? {
    nil
  }

  internal var pageMainContent: [Node<HTML.BodyContext>] {
    [.contentBody(source.body)]
  }

  internal var redirectURL: URL? {
    archiveURL
  }

  internal init(item: Item<BrightDigitSite>, site _: BrightDigitSite) throws {
    source = item
    let featuredImageURL = item.featuredImageURL
    let archiveURL = item.metadata.longArchiveURL.flatMap(URL.init(string:))
    let isFeatured = item.metadata.featured ?? false
    let issueNo = item.metadata.issueNo.flatMap(Int.init)

    guard let archiveURL = archiveURL else {
      throw PublishTypeError.missingField(MissingFields.NewsletterField.archiveURL, item)
    }

    guard let issueNo = issueNo else {
      throw PublishTypeError.missingField(MissingFields.NewsletterField.issueNo, item)
    }

    title = item.title
    description = item.description
    self.featuredImageURL = featuredImageURL
    publishedDate = item.metadata.date
    self.issueNo = issueNo
    self.archiveURL = archiveURL
    self.isFeatured = isFeatured
  }
}
