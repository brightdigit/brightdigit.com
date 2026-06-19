//
//  ItemContent.swift
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

public struct ItemContent<
  ItemType: SectionItem,
  WebsiteType
>: PageContent where ItemType.WebsiteType == WebsiteType {
  internal let item: ItemType
  internal let context: PublishingContext<WebsiteType>

  public var description: String {
    item.description
  }

  public var socialTitle: String {
    item.pageTitle
  }

  public var socialImageURL: URL {
    context.site.absoluteURL(for: item.featuredImageURL)
  }

  public var absoluteURL: URL {
    item.source.absoluteURL(forSite: context.site)
  }

  public var title: String {
    item.pageTitle
  }

  public var bodyID: String? {
    item.pageBodyID
  }

  public var bodyClasses: [String] {
    [item.source.sectionID.rawValue]
  }

  public var main: [Node<HTML.BodyContext>] {
    item.pageMainContent
  }

  public var redirectURL: URL? {
    item.redirectURL
  }

  public var canonicalURL: URL? {
    redirectURL ?? absoluteURL
  }

  public init(item: ItemType, context: PublishingContext<WebsiteType>) {
    self.item = item
    self.context = context
  }
}

extension URL {
  public init(staticString: String) {
    guard let url = URL(string: staticString) else {
      preconditionFailure("Invalid static URL string: \(staticString)")
    }
    self = url
  }
}

extension Item {
  public var rootRelativeURL: URL {
    URL(staticString: "/\(path)")
  }

  public func absoluteURL(forSite site: Site) -> URL {
    site.url(for: path)
  }
}
