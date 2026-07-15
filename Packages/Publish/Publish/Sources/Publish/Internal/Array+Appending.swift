/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Array {
  internal func appending(_ element: Element) -> Self {
    var array = self
    array.append(element)
    return array
  }
}
