/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest

extension Date {
  // A three-element tuple is the simplest shape for this test-only stub value.
  // swiftlint:disable:next large_tuple
  internal typealias Stubs = (date: Date, timeZone: TimeZone, expectedString: String)

  internal enum FormattingStyle {
    case rss
    case siteMap
  }

  internal static func makeStubs(withFormattingStyle formattingStyle: FormattingStyle) throws
    -> Stubs
  {
    let timeZone = try require(TimeZone(secondsFromGMT: 60 * 60))

    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .gregorian)
    dateComponents.timeZone = timeZone
    dateComponents.day = 17
    dateComponents.month = 10
    dateComponents.year = 2_019
    dateComponents.hour = 10
    dateComponents.minute = 15
    dateComponents.second = 5

    let date = try require(dateComponents.date)

    return (
      date,
      timeZone,
      formattingStyle.expectedString
    )
  }
}

extension Date.FormattingStyle {
  fileprivate var expectedString: String {
    switch self {
    case .rss:
      return "Thu, 17 Oct 2019 10:15:05 +0100"
    case .siteMap:
      return "2019-10-17"
    }
  }
}
