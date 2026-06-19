//
//  ProductItem+NestedTypes.swift
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

extension ProductItem {
  internal enum ScreenshotStyle: String, Codable, Equatable {
    case `default`, portrait, square
  }

  internal struct PressCoverage: Codable, Equatable, Hashable {
    internal let source: String
    internal let quote: String
    internal let url: URL
    internal let date: Date

    internal init(source: String, quote: String, url: String, date: Date) {
      self.source = source
      self.quote = quote
      guard let parsedURL = URL(string: url) else {
        preconditionFailure("Invalid PressCoverage URL: \(url)")
      }
      self.url = parsedURL
      self.date = date
    }
  }

  internal struct Image {
    internal static let basePath = "/media/products"
    internal let path: String

    fileprivate init(path: String) {
      self.path = path
    }

    internal static func logo(withName name: String?) -> Image {
      at(path: name ?? "logo.svg")
    }

    internal static func at(path: String) -> Image {
      self.init(path: path)
    }

    internal func string(basedOnSlug slug: String) -> String {
      [Self.basePath, slug, path].joined(separator: "/")
    }
  }
}
