//
//  Pages.swift
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

internal enum Pages {
  internal static func page(
    forIndex index: Index, withContext context: PublishingContext<BrightDigitSite>
  ) -> PageContent {
    DynamicPageContent(builder: IndexBuilder(), location: index, context: context)
  }

  internal static func content(
    basedOnPage page: Page,
    withContext context: PublishingContext<BrightDigitSite>
  ) throws -> PageContent {
    switch page.path.string {
    case "services":
      return ServicesBuilder().pageSetup(forPage: page, withContext: context)
    case "contact-us":
      return ContactBuilder().pageSetup(forPage: page, withContext: context)
    case "about-us": return AboutBuilder().pageSetup(forPage: page, withContext: context)
    default: throw PublishTypeError.missingContentFor(page)
    }
  }

  internal static func content(
    forSection section: Section<BrightDigitSite>,
    withContext context: PublishingContext<BrightDigitSite>
  ) throws -> PageContent {
    switch section.id.rawValue {
    case "newsletters":
      return try NewsletterItem.content(forSection: section, withContext: context)
    case "articles":
      return try ArticleItem.content(forSection: section, withContext: context)
    case "episodes":
      return try PodcastItem.content(forSection: section, withContext: context)
    case "tutorials":
      return try TutorialItem.content(forSection: section, withContext: context)
    case "products":
      return try ProductItem.content(forSection: section, withContext: context)

    default: throw PublishTypeError.missingContentFor(section)
    }
  }

  internal static func content(
    forItem item: Item<BrightDigitSite>,
    withContext context: PublishingContext<BrightDigitSite>
  ) throws -> PageContent {
    switch item.sectionID.rawValue {
    case "newsletters":
      return try NewsletterItem.content(forItem: item, withContext: context)
    case "articles": return try ArticleItem.content(forItem: item, withContext: context)
    case "episodes": return try PodcastItem.content(forItem: item, withContext: context)
    case "tutorials": return try TutorialItem.content(forItem: item, withContext: context)
    case "products": return try ProductItem.content(forItem: item, withContext: context)

    default: throw PublishTypeError.missingContentFor(item)
    }
  }
}
