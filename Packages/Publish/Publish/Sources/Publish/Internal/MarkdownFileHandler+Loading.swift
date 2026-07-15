/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files

extension MarkdownFileHandler {
  internal enum FolderResult {
    case pages([Page])
    case section(id: Site.SectionID, content: Content?, items: [Item<Site>])
  }

  internal func addIndexFile(
    in folder: Folder,
    to context: inout PublishingContext<Site>,
    using factory: MarkdownContentFactory<Site>
  ) throws {
    if let indexFile = try? folder.file(named: "index.md") {
      do {
        context.index.content = try factory.makeContent(fromFile: indexFile)
      } catch {
        throw wrap(error, forPath: "\(folder.path)index.md")
      }
    }
  }

  internal func makeFolderResult(
    for subfolder: Folder,
    rootFolder folder: Folder,
    factory: MarkdownContentFactory<Site>
  ) async throws -> FolderResult {
    guard let sectionID = Site.SectionID(rawValue: subfolder.name.lowercased()) else {
      let pages = try await makePagesForMarkdownFiles(
        inFolder: subfolder,
        recursively: true,
        parentPath: Path(subfolder.name),
        factory: factory
      )
      return .pages(pages)
    }

    var sectionContent: Content?
    var items = [Item<Site>]()

    for file in subfolder.files.recursive where file.isMarkdown {
      if file.nameExcludingExtension == "index", file.parent == subfolder {
        sectionContent = try factory.makeContent(fromFile: file)
        continue
      }

      items.append(
        try makeSectionItem(
          from: file,
          in: subfolder,
          rootFolder: folder,
          sectionID: sectionID,
          factory: factory
        )
      )
    }

    return .section(id: sectionID, content: sectionContent, items: items)
  }

  fileprivate func makeSectionItem(
    from file: File,
    in subfolder: Folder,
    rootFolder folder: Folder,
    sectionID: Site.SectionID,
    factory: MarkdownContentFactory<Site>
  ) throws -> Item<Site> {
    do {
      let fileName = file.nameExcludingExtension
      let path: Path

      if let parentPath = file.parent?.path(relativeTo: subfolder) {
        path = Path(parentPath).appendingComponent(fileName)
      } else {
        path = Path(fileName)
      }

      return try factory.makeItem(
        fromFile: file,
        at: path,
        sectionID: sectionID
      )
    } catch {
      let path = Path(file.path(relativeTo: folder))
      throw wrap(error, forPath: path)
    }
  }

  internal func apply(
    _ results: [FolderResult],
    to context: inout PublishingContext<Site>
  ) {
    for result in results {
      switch result {
      case .pages(let pages):
        for page in pages {
          context.addPage(page)
        }
      case .section(let id, let content, let items):
        addSection(id: id, content: content, items: items, to: &context)
      }
    }
  }

  fileprivate func addSection(
    id: Site.SectionID,
    content: Content?,
    items: [Item<Site>],
    to context: inout PublishingContext<Site>
  ) {
    if let content = content {
      context.sections[id].content = content
    }

    for item in items {
      context.addItem(item)
    }
  }

  internal func makePagesForMarkdownFiles(
    inFolder folder: Folder,
    recursively: Bool,
    parentPath: Path,
    factory: MarkdownContentFactory<Site>
  ) async throws -> [Page] {
    var pages = [Page]()

    for file in folder.files where file.isMarkdown {
      if file.nameExcludingExtension == "index", !recursively {
        continue
      }

      let pagePath = parentPath.appendingComponent(file.nameExcludingExtension)
      pages.append(try factory.makePage(fromFile: file, at: pagePath))
    }

    guard recursively else {
      return pages
    }

    for subfolder in folder.subfolders {
      let subfolderPath = parentPath.appendingComponent(subfolder.name)

      pages += try await makePagesForMarkdownFiles(
        inFolder: subfolder,
        recursively: true,
        parentPath: subfolderPath,
        factory: factory
      )
    }

    return pages
  }

  fileprivate func wrap(_ error: Error, forPath path: Path) -> Error {
    if error is FilesError<ReadErrorReason> {
      return FileIOError(path: path, reason: .fileCouldNotBeRead)
    } else if let error = error as? DecodingError {
      switch error {
      case .keyNotFound(_, let context),
        .valueNotFound(_, let context):
        return ContentError(
          path: path,
          reason: .markdownMetadataDecodingFailed(
            context: context,
            valueFound: false
          )
        )
      case .typeMismatch(_, let context),
        .dataCorrupted(let context):
        return ContentError(
          path: path,
          reason: .markdownMetadataDecodingFailed(
            context: context,
            valueFound: true
          )
        )
      @unknown default:
        return ContentError(
          path: path,
          reason: .markdownMetadataDecodingFailed(
            context: nil,
            valueFound: true
          )
        )
      }
    } else {
      return error
    }
  }
}

extension File {
  private static let markdownFileExtensions: Set<String> = [
    "md", "markdown", "txt", "text",
  ]

  fileprivate var isMarkdown: Bool {
    self.extension.map(File.markdownFileExtensions.contains) ?? false
  }
}
