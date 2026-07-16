//
//  Testimonial.swift
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

public struct Testimonial: Hashable, Comparable, Sendable {
  internal static let all: Set<Self> = .init([
    .derekDeJonghe, .daveCIO, .tomAssetHealth, .daveAM, .jody, .flickCMC, .hrAssetHealth,
    .davidSmith, .edCMC,
  ])

  internal let id: Int
  internal let fullName: String
  internal let title: String

  internal let fullQuote: String
  internal let briefQuote: String

  internal let url: URL?

  internal init(
    id: Int,
    fullName: String,
    title: String,
    fullQuote: String,
    briefQuote: String? = nil,
    url: URL? = nil
  ) {
    self.id = id
    self.fullName = fullName
    self.title = title
    self.fullQuote = fullQuote
    self.briefQuote = briefQuote ?? fullQuote
    self.url = url
  }

  public static func == (lhs: Testimonial, rhs: Testimonial) -> Bool {
    lhs.id == rhs.id
  }

  public static func < (lhs: Testimonial, rhs: Testimonial) -> Bool {
    lhs.id < rhs.id
  }
}

extension Testimonial {
  internal static func listItem(_ testimonial: Testimonial) -> Component {
    ListItem {
      Element(name: "figure") {
        Element(name: "blockquote") {
          Paragraph { Text(testimonial.briefQuote) }
        }
        Element(name: "figcaption") {
          Text("-")
          Text(testimonial.fullName)
          Text(", ")
          Element(name: "cite") { Text(testimonial.title) }
        }
      }
    }
  }
}
