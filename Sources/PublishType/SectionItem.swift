//
//  SectionItem.swift
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

public protocol SectionItem: SectionContentFactory {
  static var sectionH1: String? { get }
  static var sectionTitle: String { get }
  static var sectionDescription: String { get }
  var featuredItemContent: Node<HTML.BodyContext> { get }
  var sectionItemContent: [Node<HTML.BodyContext>] { get }
  var isFeatured: Bool { get }
  var source: Item<WebsiteType> { get }
  var description: String { get }
  var pageTitle: String { get }

  var pageBodyID: String? { get }

  var pageMainContent: [Node<HTML.BodyContext>] { get }

  var redirectURL: URL? { get }
  var featuredImageURL: URL { get }

  init(item: Item<WebsiteType>, site: WebsiteType) throws
}
