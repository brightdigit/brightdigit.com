//
//  DynamicPageContent.swift
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

public struct DynamicPageContent<
  BuilderType: ContentBuilder,
  WebsiteType
>: PageContent where BuilderType.WebsiteType == WebsiteType {
  public var description: String {
    builder.description
  }

  public var socialTitle: String {
    title
  }

  public var socialImageURL: URL {
    context.site.url(for: builder.imagePath)
  }

  public var absoluteURL: URL {
    context.site.url(for: location)
  }

  public var canonicalURL: URL? {
    absoluteURL
  }

  internal let builder: BuilderType
  internal let location: BuilderType.LocationType
  internal let context: PublishingContext<WebsiteType>

  public var title: String {
    if let site = WebsiteType.self as? MetadataAttached.Type,
      BuilderType.self.LocationType == Index.self
    {
      return site.metadata.title
    } else {
      return location.title
    }
  }

  public var main: Component {
    builder.main(forLocation: location, withContext: context)
  }

  public var bodyID: String? {
    location.path.string
  }

  public var bodyClasses: [String] {
    builder.bodyClasses
  }

  public var redirectURL: URL? {
    nil
  }

  public init(
    builder: BuilderType,
    location: BuilderType.LocationType,
    context: PublishingContext<WebsiteType>
  ) {
    self.builder = builder
    self.location = location
    self.context = context
  }
}
