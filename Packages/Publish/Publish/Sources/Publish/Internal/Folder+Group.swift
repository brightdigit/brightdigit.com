/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files

extension Folder {
  internal struct Group: Sendable {
    internal let root: Folder
    internal let output: Folder
    internal let `internal`: Folder
    internal let caches: Folder
  }
}
