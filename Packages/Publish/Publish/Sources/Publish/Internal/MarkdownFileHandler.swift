/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files

internal struct MarkdownFileHandler<Site: Website> {
  internal func addMarkdownFiles(
    in folder: Folder,
    to context: inout PublishingContext<Site>
  ) async throws {
    let factory = context.makeMarkdownContentFactory()

    try addIndexFile(in: folder, to: &context, using: factory)

    var folderResults = [FolderResult]()
    for subfolder in folder.subfolders {
      let result = try await makeFolderResult(
        for: subfolder,
        rootFolder: folder,
        factory: factory
      )
      folderResults.append(result)
    }

    apply(folderResults, to: &context)

    let rootPages = try await makePagesForMarkdownFiles(
      inFolder: folder,
      recursively: false,
      parentPath: "",
      factory: factory
    )

    for page in rootPages {
      context.addPage(page)
    }
  }
}
