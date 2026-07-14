/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files

internal struct MarkdownFileHandler<Site: Website> {
    func addMarkdownFiles(
        in folder: Folder,
        to context: inout PublishingContext<Site>
    ) async throws {
        let factory = context.makeMarkdownContentFactory()

        if let indexFile = try? folder.file(named: "index.md") {
            do {
                context.index.content = try factory.makeContent(fromFile: indexFile)
            } catch {
                throw wrap(error, forPath: "\(folder.path)index.md")
            }
        }

        var folderResults = [FolderResult]()

        for subfolder in folder.subfolders {
            guard let sectionID = Site.SectionID(rawValue: subfolder.name.lowercased()) else {
                folderResults.append(.pages(try await makePagesForMarkdownFiles(
                    inFolder: subfolder,
                    recursively: true,
                    parentPath: Path(subfolder.name),
                    factory: factory
                )))
                continue
            }

            var sectionContent: Content?
            var items = [Item<Site>]()

            for file in subfolder.files.recursive {
                guard file.isMarkdown else { continue }

                if file.nameExcludingExtension == "index", file.parent == subfolder {
                    sectionContent = try factory.makeContent(fromFile: file)
                    continue
                }

                do {
                    let fileName = file.nameExcludingExtension
                    let path: Path

                    if let parentPath = file.parent?.path(relativeTo: subfolder) {
                        path = Path(parentPath).appendingComponent(fileName)
                    } else {
                        path = Path(fileName)
                    }

                    items.append(try factory.makeItem(
                        fromFile: file,
                        at: path,
                        sectionID: sectionID
                    ))
                } catch {
                    let path = Path(file.path(relativeTo: folder))
                    throw wrap(error, forPath: path)
                }
            }

            folderResults.append(.section(id: sectionID, content: sectionContent, items: items))
        }

        for result in folderResults {
            switch result {
            case .pages(let pages):
                for page in pages {
                    context.addPage(page)
                }
            case .section(let id, let content, let items):
                if let content = content {
                    context.sections[id].content = content
                }

                for item in items {
                    context.addItem(item)
                }
            }
        }

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

private extension MarkdownFileHandler {
    enum FolderResult {
        case pages([Page])
        case section(id: Site.SectionID, content: Content?, items: [Item<Site>])
    }

    func makePagesForMarkdownFiles(
        inFolder folder: Folder,
        recursively: Bool,
        parentPath: Path,
        factory: MarkdownContentFactory<Site>
    ) async throws -> [Page] {
        var pages = [Page]()

        for file in folder.files {
            guard file.isMarkdown else { continue }

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

    func wrap(_ error: Error, forPath path: Path) -> Error {
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

private extension File {
    private static let markdownFileExtensions: Set<String> = [
        "md", "markdown", "txt", "text"
    ]

    var isMarkdown: Bool {
        self.extension.map(File.markdownFileExtensions.contains) ?? false
    }
}
