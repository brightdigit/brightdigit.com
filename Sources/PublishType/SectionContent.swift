//
//  SectionContent.swift
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

public struct SectionContent<SectionBuilderType: SectionBuilderProtocol>: PageContent {
  internal let builder: SectionBuilderType
  internal let context: PublishingContext<SectionBuilderType.WebsiteType>

  public var description: String {
    builder.description
  }

  public var socialTitle: String {
    title
  }

  public var socialImageURL: URL {
    if builder.featuredItem.featuredImageURL.path.isEmpty {
      return builder.featuredItem.featuredImageURL.absoluteURL
    } else {
      let path = Path(builder.featuredItem.featuredImageURL.path)
      return context.site.url(for: path)
    }
  }

  public var absoluteURL: URL {
    context.site.url(for: builder.section)
  }

  public var title: String {
    builder.title
  }

  public var bodyClasses: [String] {
    []
  }

  public var bodyID: String? {
    builder.section.id.rawValue
  }

  public var main: [Node<HTML.BodyContext>] {
    [
      .class("section"),
      .unwrap(builder.header1) { text in
        .header(
          .h1(.text(text))
        )
      },
      featuredNode,
      .section(
        .ol(
          .forEach(builder.children) {
            .li(
              .forEach($0.sectionItemContent) { $0 }
            )
          }
        )
      ),
    ]
  }

  public var featuredNode: Node<HTML.BodyContext> {
    builder.featuredItem.featuredItemContent
  }

  public var redirectURL: URL? {
    nil
  }

  public var canonicalURL: URL? {
    context.site.url(for: builder.section.path)
  }

  public init(
    builder: SectionBuilderType,
    context: PublishingContext<SectionBuilderType.WebsiteType>
  ) {
    self.builder = builder
    self.context = context
  }
}

extension Website {
  internal func absoluteURL(for url: URL) -> URL {
    if url.path.isEmpty || url.host != nil {
      return url
    } else {
      let path = Path(url.path)
      return self.url(for: path)
    }
  }
}
