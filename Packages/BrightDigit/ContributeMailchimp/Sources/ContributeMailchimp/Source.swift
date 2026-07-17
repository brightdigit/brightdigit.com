//
//  Source.swift
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

import Contribute
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
extension Newsletter {
  /// A fully-resolved newsletter issue: the campaign metadata together with its
  /// rendered HTML and Markdown.
  public struct Source: Sendable {
    public let slug: String
    public let issueNo: Int
    public let campaignID: String
    public let longArchiveURL: URL
    public let featuredImageURL: URL?
    public let title: String
    public let subjectLine: String
    public let previewText: String?
    public let sendTime: Date
    public let html: String
    public let markdown: String

    init(campaign: Campaign, html: String, markdown: String) {
      slug = campaign.slug
      issueNo = campaign.issueNo
      campaignID = campaign.campaignID
      longArchiveURL = campaign.longArchiveURL
      featuredImageURL = campaign.featuredImageURL
      title = campaign.title
      subjectLine = campaign.subjectLine
      previewText = campaign.previewText?.dequote().fixUnicodeEscape()
      sendTime = campaign.sendTime
      self.html = html
      self.markdown = markdown
    }
  }
}
