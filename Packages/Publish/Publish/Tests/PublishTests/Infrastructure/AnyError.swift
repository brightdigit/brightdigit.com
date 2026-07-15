/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

internal struct AnyError: LocalizedError {
  internal var errorDescription: String?

  internal init(_ string: String) {
    errorDescription = string
  }
}
