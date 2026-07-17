//
//  Home+LatestArticle.swift
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

extension Home {
  /// One article card in the homepage “Latest” list.
  internal struct LatestArticle: Component {
    internal let article: IndexArticle

    internal var body: Component {
      ListItem {
        Header {
          Link(url: article.rootRelativeURL) {
            // No `alt`, so a raw img node (Image would inject `alt=""`).
            Node<HTML.BodyContext>.img(.src(article.featuredImageURL))
            H3 { Text(article.title) }
          }
          Element(name: "ol") {
            for tag in article.tags {
              ListItem { Text(tag.string) }
            }
          }
        }
        Main {
          Paragraph { Text(article.description) }
        }
        Footer {
          Link(url: article.rootRelativeURL) {
            Div {
              Text(PiHTMLFactory.itemFormatter.string(from: article.publishedAt))
            }.class("publishedAt")
            Div {
              Text("\(article.lengthInMinutes) mins")
            }.class("readTime")
          }
        }
      }
    }
  }
}
