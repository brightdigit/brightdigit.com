/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

extension String {
  internal static func unique() -> String {
    UUID().uuidString
  }
}
