/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension String {
  /// Returns the substring located between the first occurrence of `start`
  /// and the following occurrence of `end`, or `nil` if either marker is
  /// absent. Stdlib replacement for Sweep's `firstSubstring(between:and:)` /
  /// `substrings(between:and:).first`, used by the feed-generation tests.
  internal func firstSubstring(between start: String, and end: String) -> String? {
    guard let startRange = range(of: start),
      let endRange = self[startRange.upperBound...].range(of: end)
    else {
      return nil
    }

    return String(self[startRange.upperBound..<endRange.lowerBound])
  }
}
