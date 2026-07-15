/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Plot

internal struct HTMLGenerator<Site: Website> {
  internal let theme: Theme<Site>
  internal let indentation: Indentation.Kind?
  internal let fileMode: HTMLFileMode
  internal let context: PublishingContext<Site>

  internal func generate() async throws {
    // These steps read from the shared, non-Sendable `PublishingContext`
    // and write to the output folder, so they are run sequentially rather
    // than in a task group to remain data-race safe under strict concurrency.
    try await copyThemeResources()
    try generateIndexHTML()
    try await generateSectionHTML()
    try await generatePageHTML()
    try await generateTagHTMLIfNeeded()
  }
}

extension HTMLGenerator {
  fileprivate func copyThemeResources() async throws {
    guard !theme.resourcePaths.isEmpty else {
      return
    }

    let creationFile = try File(path: theme.creationPath.string)
    let packageFolder = try creationFile.resolveSwiftPackageFolder()

    for path in theme.resourcePaths {
      do {
        let file = try packageFolder.file(at: path.string)
        try context.copyFileToOutput(file, targetFolderPath: nil)
      } catch {
        throw PublishingError(
          path: path,
          infoMessage: "Failed to copy theme resource",
          underlyingError: error
        )
      }
    }
  }

  fileprivate func generateIndexHTML() throws {
    let html = try theme.makeIndexHTML(context.index, context)
    let indexFile = try context.createOutputFile(at: "index.html")
    try indexFile.write(html.render(indentedBy: indentation))
  }

  fileprivate func generateSectionHTML() async throws {
    for section in context.sections {
      try outputHTML(
        for: section,
        indentedBy: indentation,
        using: theme.makeSectionHTML,
        fileMode: .foldersAndIndexFiles
      )

      for item in section.items {
        try outputHTML(
          for: item,
          indentedBy: indentation,
          using: theme.makeItemHTML,
          fileMode: fileMode
        )
      }
    }
  }

  fileprivate func generatePageHTML() async throws {
    for page in context.pages.values {
      try outputHTML(
        for: page,
        indentedBy: indentation,
        using: theme.makePageHTML,
        fileMode: fileMode
      )
    }
  }

  fileprivate func generateTagHTMLIfNeeded() async throws {
    guard let config = context.site.tagHTMLConfig else {
      return
    }

    let listPage = TagListPage(
      tags: context.allTags,
      path: config.basePath,
      content: config.listContent ?? .init()
    )

    if let listHTML = try theme.makeTagListHTML(listPage, context) {
      let listPath = Path("\(config.basePath)/index.html")
      let listFile = try context.createOutputFile(at: listPath)
      try listFile.write(listHTML.render(indentedBy: indentation))
    }

    for tag in context.allTags {
      let detailsPath = context.site.path(for: tag)
      let detailsContent = config.detailsContentResolver(tag)

      let detailsPage = TagDetailsPage(
        tag: tag,
        path: detailsPath,
        content: detailsContent ?? .init()
      )

      guard let detailsHTML = try theme.makeTagDetailsHTML(detailsPage, context) else {
        continue
      }

      try outputHTML(
        for: detailsPage,
        indentedBy: indentation,
        using: { _, _ in detailsHTML },
        fileMode: fileMode
      )
    }
  }

  fileprivate func outputHTML<T: Location>(
    for location: T,
    indentedBy indentation: Indentation.Kind?,
    using generator: (T, PublishingContext<Site>) throws -> HTML,
    fileMode: HTMLFileMode
  ) throws {
    let html = try generator(location, context)
    let path = filePath(for: location, fileMode: fileMode)
    let file = try context.createOutputFile(at: path)
    try file.write(html.render(indentedBy: indentation))
  }

  fileprivate func filePath(for location: Location, fileMode: HTMLFileMode) -> Path {
    switch fileMode {
    case .foldersAndIndexFiles:
      return "\(location.path)/index.html"
    case .standAloneFiles:
      return "\(location.path).html"
    }
  }
}
