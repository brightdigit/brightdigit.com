//
//  PostItem.swift
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

internal struct PostItem<PostableType: Postable>: SectionItem {
  internal typealias WebsiteType = BrightDigitSite
  internal static var sectionH1: String? {
    PostableType.sectionH1
  }

  internal static var sectionDescription: String {
    PostableType.sectionDescription
  }

  internal static var sectionTitle: String {
    PostableType.sectionTitle
  }

  internal let slug: String
  internal let description: String
  internal let featuredImageURL: URL
  internal let title: String
  internal let publishedDate: Date
  internal let source: Item<BrightDigitSite>
  internal let site: BrightDigitSite
  internal let subscriptionCTA: String?

  internal let isFeatured: Bool

  internal var pageTitle: String {
    title
  }

  internal var pageBodyID: String? {
    nil
  }

  internal var absoluteURL: URL {
    source.absoluteURL(forSite: site)
  }

  internal var pageMainContent: [Node<HTML.BodyContext>] {
    [
      pageHeader,
      .main(.contentBody(source.body)),
      pageFooter,
    ]
  }

  internal var redirectURL: URL? {
    nil
  }

  internal init(item: Item<BrightDigitSite>, site: BrightDigitSite) throws {
    source = item
    self.site = site
    let featuredImageURL = item.featuredImageURL
    let isFeatured = item.metadata.featured ?? false

    subscriptionCTA = item.metadata.subscriptionCTA
    slug = item.path.string
    title = item.title
    description = item.description
    self.featuredImageURL = featuredImageURL
    publishedDate = item.metadata.date
    self.isFeatured = isFeatured
  }
}
