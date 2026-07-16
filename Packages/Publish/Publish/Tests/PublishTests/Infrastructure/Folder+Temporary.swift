/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Foundation

extension Folder {
  internal static func createTemporary() throws -> Self {
    let parent = try createTestsFolder()
    return try parent.createSubfolder(named: .unique())
  }
}

extension Folder {
  fileprivate static func createTestsFolder() throws -> Self {
    try Folder.temporary.createSubfolderIfNeeded(at: "PublishTests")
  }
}
