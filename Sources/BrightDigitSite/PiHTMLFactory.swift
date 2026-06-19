//
//  PiHTMLFactory.swift
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

internal struct PiHTMLFactory: HTMLFactory {
  internal typealias Site = BrightDigitSite

  internal static let yearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter
  }()

  internal static let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
  }()

  internal static let formatTimeIntervalSufficies = ["h", "m"]

  internal static func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
    let hoursDouble = floor(timeInterval / 60.0 / 60.0)
    let minutesDouble = (timeInterval - (hoursDouble * 60.0 * 60.0)) / 60.0
    return [hoursDouble, minutesDouble]
      .map(Int.init)
      .enumerated()
      .compactMap { index, value in
        guard value > 0 else {
          return nil
        }
        return ["\(value)", formatTimeIntervalSufficies[index]].joined()
      }
      .joined(separator: " ")
  }

  // MARK: - makeIndexHTML

  internal func makeIndexHTML(
    for index: Index,
    context: PublishingContext<BrightDigitSite>
  ) throws -> HTML {
    let setup = Pages.page(forIndex: index, withContext: context)
    return HTML(
      .lang(.usEnglish),
      .head(forPage: setup),
      .body(
        .header(),
        setup.mainElement,
        .footer()
      )
    )
  }

  // MARK: - makeSectionHTML

  internal func makeSectionHTML(
    for section: Section<BrightDigitSite>,
    context: PublishingContext<BrightDigitSite>
  ) throws -> HTML {
    let content = try Pages.content(forSection: section, withContext: context)

    return HTML(
      .lang(.usEnglish),
      .head(forPage: content),
      .body(
        .unwrap(content.bodyID, Node.id),
        .unwrap(content.bodyClassValue, Node.class),
        .header(),
        content.mainElement,
        .footer()
      )
    )
  }

  // MARK: - makeItemHTML

  internal func makeItemHTML(
    for item: Item<BrightDigitSite>, context: PublishingContext<BrightDigitSite>
  ) throws -> HTML {
    let content = try Pages.content(forItem: item, withContext: context)
    return HTML(
      .lang(.usEnglish),
      .head(forPage: content),
      .body(
        .unwrap(content.bodyID, Node.id),
        .unwrap(content.bodyClassValue, Node.class),
        .header(),
        content.mainElement,
        .footer()
      )
    )
  }

  // MARK: - makePageHTML

  internal func makePageHTML(for page: Page, context: PublishingContext<BrightDigitSite>)
    throws
    -> HTML
  {
    let content = try Pages.content(basedOnPage: page, withContext: context)
    return HTML(
      .lang(.usEnglish),
      .head(forPage: content),
      .body(
        .unwrap(content.bodyID, Node.id),
        .unwrap(content.bodyClassValue, Node.class),
        .header(),
        content.mainElement,
        .footer()
      )
    )
  }

  // MARK: - makeTagListHTML

  internal func makeTagListHTML(
    for _: TagListPage, context _: PublishingContext<BrightDigitSite>
  )
    throws -> HTML?
  {
    nil
  }

  // MARK: - makeTagDetailsHTML

  internal func makeTagDetailsHTML(
    for _: TagDetailsPage, context _: PublishingContext<BrightDigitSite>
  ) throws -> HTML? {
    nil
  }
}

// MARK: - Theme

extension Theme where Site == BrightDigitSite {
  internal static var company: Self {
    Theme(htmlFactory: PiHTMLFactory())
  }
}
