//
//  Newsletter+FeaturedCard.swift
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

extension Newsletter {
  /// The featured newsletter hero card shown on the newsletters index.
  internal struct FeaturedCard: Component {
    internal let title: String
    internal let description: String
    internal let featuredImageURL: URL
    internal let archiveURL: URL
    internal let publishedDate: Date
    internal let sourcePath: String

    internal var body: Component {
      Header {
        Element(name: "section") {
          H1 {
            Text("Don't Let Your App")
            Element(name: "em") { Text("Fall Behind") }
          }
          Paragraph { Text("\(Strings.Newsletter.featuredParagraph)") }
        }
        Element(name: "section") {
          Newsletter.SubscriptionForm(sourcePath: sourcePath)
          Element(name: "section") {
            Header {
              H3 { Text("Featured issue") }
              Image(featuredImageURL)
              Link(url: archiveURL) {
                H2 { Text(title) }
              }
            }
            Main {
              Text(description)
            }
            Newsletter.ItemFooter(publishedDate: publishedDate)
          }.class("featured")
        }.class("hero")
      }
    }
  }
}
