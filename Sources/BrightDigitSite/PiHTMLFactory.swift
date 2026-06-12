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
