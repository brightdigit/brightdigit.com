/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot
import Files
import CollectionConcurrencyKit

internal struct HTMLGenerator<Site: Website> {
    let theme: Theme<Site>
    let indentation: Indentation.Kind?
    let fileMode: HTMLFileMode
    let context: PublishingContext<Site>

    func generate() async throws {
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

private extension HTMLGenerator {
    func copyThemeResources() async throws {
        guard !theme.resourcePaths.isEmpty else {
            return
        }

        let creationFile = try File(path: theme.creationPath.string)
        let packageFolder = try creationFile.resolveSwiftPackageFolder()

        try await theme.resourcePaths.asyncForEach { path in
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

    func generateIndexHTML() throws {
        let html = try theme.makeIndexHTML(context.index, context)
        let indexFile = try context.createOutputFile(at: "index.html")
        try indexFile.write(html.render(indentedBy: indentation))
    }

    func generateSectionHTML() async throws {
        try await context.sections.asyncForEach { section in
            try outputHTML(
                for: section,
                indentedBy: indentation,
                using: theme.makeSectionHTML,
                fileMode: .foldersAndIndexFiles
            )
            
            try await section.items.asyncForEach { item in
                try outputHTML(
                    for: item,
                    indentedBy: indentation,
                    using: theme.makeItemHTML,
                    fileMode: fileMode
                )
            }
        }
    }

    func generatePageHTML() async throws {
        try await context.pages.values.asyncForEach { page in
            try outputHTML(
                for: page,
                indentedBy: indentation,
                using: theme.makePageHTML,
                fileMode: fileMode
            )
        }
    }

    func generateTagHTMLIfNeeded() async throws {
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

        try await context.allTags.asyncForEach { tag in
            let detailsPath = context.site.path(for: tag)
            let detailsContent = config.detailsContentResolver(tag)

            let detailsPage = TagDetailsPage(
                tag: tag,
                path: detailsPath,
                content: detailsContent ?? .init()
            )

            guard let detailsHTML = try theme.makeTagDetailsHTML(detailsPage, context) else {
                return
            }

            try outputHTML(
                for: detailsPage,
                indentedBy: indentation,
                using: { _, _ in detailsHTML },
                fileMode: fileMode
            )
        }
    }

    func outputHTML<T: Location>(
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

    func filePath(for location: Location, fileMode: HTMLFileMode) -> Path {
        switch fileMode {
        case .foldersAndIndexFiles:
            return "\(location.path)/index.html"
        case .standAloneFiles:
            return "\(location.path).html"
        }
    }
}
