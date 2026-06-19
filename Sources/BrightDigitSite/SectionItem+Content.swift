//
//  SectionItem+Content.swift
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

import Publish
import PublishType

extension SectionItem {
  internal static func content(
    forSection section: Section<WebsiteType>,
    withContext context: PublishingContext<WebsiteType>
  ) throws -> PageContent where WebsiteType == BrightDigitSite {
    let allChildren = try section.items.map {
      try Self(item: $0, site: context.site)
    }
    let featuredIndex =
      allChildren.firstIndex(where: { $0.isFeatured }) ?? allChildren.startIndex
    var children = allChildren
    children.remove(at: featuredIndex)
    let sortedChildren =
      children.filter { $0.isFeatured } + children.filter { !$0.isFeatured }
    let builder = SectionBuilder(
      section: section, children: sortedChildren, featuredItem: allChildren[featuredIndex]
    )
    return SectionContent(builder: builder, context: context)
  }

  internal static func content(
    forItem item: Item<WebsiteType>, withContext context: PublishingContext<WebsiteType>
  ) throws -> PageContent {
    let object = try Self(item: item, site: context.site)
    return ItemContent(item: object, context: context)
  }
}
