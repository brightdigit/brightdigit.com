//
//  PostItem+Content.swift
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

extension PostItem {
  private var shareListItems: [Post.ShareListItem] {
    SocialShares.shares.map { share in
      Post.ShareListItem(
        shareURL: share.shareURL(for: self),
        actionText: share.actionText,
        nameText: share.nameText,
        flaticonName: share.flaticonName
      )
    }
  }

  internal var featuredItemContent: Component {
    Post.FeaturedCard(
      title: title,
      description: description,
      featuredImageURL: featuredImageURL,
      sourcePathAbsolute: source.path.absoluteString,
      publishedDate: publishedDate
    )
  }

  internal var sectionItemContent: Component {
    ListItem {
      Post.SectionCard(
        title: title,
        description: description,
        featuredImageURL: featuredImageURL,
        sourcePathAbsolute: source.path.absoluteString,
        publishedDate: publishedDate
      )
    }
    .id("post-\(slug)")
  }

  internal var pageHeader: some Component {
    Post.PageHeader(
      title: title,
      featuredImageURL: featuredImageURL,
      shareItems: shareListItems,
      readingTimeMinutes: source.readingTime.minutes
    )
  }

  internal var pageFooter: some Component {
    Post.PageFooter(
      shareItems: shareListItems,
      subscriptionCTA: subscriptionCTA,
      sourcePath: source.path.string
    )
  }
}
