/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Foundation
import Ink
import Plot
import Synchronization

extension PublishingContext {
  /// Retrieve a folder at a given path, starting from the website's root folder.
  /// - parameter path: The path to retrieve a folder for.
  /// - throws: An error in case the folder couldn't be found.
  /// - Returns: The folder at the given path.
  public func folder(at path: Path) throws -> Folder {
    do { return try folders.root.subfolder(at: path.string) } catch {
      throw FileIOError(path: path, reason: .folderNotFound)
    }
  }

  /// Retrieve a file at a given path, starting from the website's root folder.
  /// - parameter path: The path to retrieve a file for.
  /// - throws: An error in case the file couldn't be found.
  /// - Returns: The file at the given path.
  public func file(at path: Path) throws -> File {
    do { return try folders.root.file(at: path.string) } catch {
      throw FileIOError(path: path, reason: .fileNotFound)
    }
  }

  /// Retrieve a folder within the website's output folder.
  /// - parameter path: The path to retrieve a folder for.
  /// - Returns: The output folder at the given path.
  /// - throws: An error in case the folder couldn't be found.
  public func outputFolder(at path: Path) throws -> Folder {
    do { return try folders.output.subfolder(at: path.string) } catch {
      throw FileIOError(path: path, reason: .folderNotFound)
    }
  }

  /// Retrieve a file within the website's output folder.
  /// - Returns: The output file at the given path.
  /// - parameter path: The path to retrieve a file for.
  /// - throws: An error in case the file couldn't be found.
  public func outputFile(at path: Path) throws -> File {
    do { return try folders.output.file(at: path.string) } catch {
      throw FileIOError(path: path, reason: .fileNotFound)
    }
  }

  /// Create a folder at a given path, starting from the website's root folder.
  /// - parameter path: The path to create a folder at.
  /// - throws: An error in case the folder couldn't be created.
  /// - Returns: The newly created folder.
  public func createFolder(at path: Path) throws -> Folder {
    try createFolder(at: path, in: folders.root)
  }

  /// Create a file at a given path, starting from the website's root folder.
  /// - parameter path: The path to create a file at.
  /// - throws: An error in case the file couldn't be created.
  /// - Returns: The newly created file.
  public func createFile(at path: Path) throws -> File {
    try createFile(at: path, in: folders.root)
  }

  /// Create a folder at a given path within the website's output folder.
  /// - parameter path: The path to create a folder at.
  /// - throws: An error in case the folder couldn't be created.
  /// - Returns: The newly created output folder.
  public func createOutputFolder(at path: Path) throws -> Folder {
    try createFolder(at: path, in: folders.output)
  }

  /// Create a file at a given path within the website's output folder.
  /// - parameter path: The path to create a file at.
  /// - throws: An error in case the file couldn't be created.
  /// - Returns: The newly created output file.
  public func createOutputFile(at path: Path) throws -> File {
    try createFile(at: path, in: folders.output)
  }

  /// Copy a folder at a given path into the website's output folder.
  /// - Throws: An error if the folder couldn’t be copied.
  /// - Parameters:
  ///   - originPath: The path of the folder to copy.
  ///   - targetFolderPath: Any specific path to copy the folder to.
  ///       If `nil`, then the folder will be copied to the output folder itself.
  public func copyFolderToOutput(
    from originPath: Path,
    to targetFolderPath: Path? = nil
  ) throws {
    let folder = try self.folder(at: originPath)
    try copyFolderToOutput(folder, targetFolderPath: targetFolderPath)
  }

  /// Copy a file at a given path into the website's output folder.
  /// - Throws: An error if the file couldn’t be copied.
  /// - Parameters:
  ///   - originPath: The path of the file to copy.
  ///   - targetFolderPath: Any specific folder path to copy the file to.
  ///       If `nil`, then the file will be copied to the output folder itself.
  public func copyFileToOutput(
    from originPath: Path,
    to targetFolderPath: Path? = nil
  ) throws {
    let file = try self.file(at: originPath)
    try copyFileToOutput(file, targetFolderPath: targetFolderPath)
  }

  /// Return either an existing or newly created cache file for the
  /// current publishing step. Cache files are scoped to the step
  /// that they're created within, and can't be shared among steps.
  /// Cache files aren't deleted in between publishing processes.
  /// - parameter name: The name of the cache file to return.
  /// - throws: An error in case a new file couldn't be created.
  /// - Returns: The cache file for the current publishing step.
  public func cacheFile(named name: String) throws -> File {
    let folderName = stepName.normalized()
    let folder = try folders.caches.createSubfolderIfNeeded(withName: folderName)
    return try folder.createFileIfNeeded(withName: name.normalized())
  }

  /// Return all items within this website, sorted by a given key path.
  /// - Parameters:
  ///   - sortingKeyPath: The key path to sort the items by.
  ///   - order: The order to use when sorting the items.
  /// - Returns: The matching items.
  public func allItems<T: Comparable>(
    sortedBy sortingKeyPath: KeyPath<Item<Site>, T>,
    order: SortOrder = .ascending
  ) -> [Item<Site>] {
    let items = sections.flatMap { $0.items }

    return items.sorted(
      by: order.makeSorter(forKeyPath: sortingKeyPath)
    )
  }

  /// Return all items that were tagged with a given tag.
  /// - parameter tag: The tag to return all items for.
  /// - Returns: The matching items.
  public func items(taggedWith tag: Tag) -> [Item<Site>] {
    sections.flatMap { $0.items(taggedWith: tag) }
  }

  /// Return all items that were tagged with a given tag, sorted by
  /// - Returns: The matching items.
  /// a given key path.
  /// - Parameters:
  ///   - tag: The tag to return all items for.
  ///   - sortingKeyPath: The key path to sort the items by.
  ///   - order: The order to use when sorting the items.
  public func items<T: Comparable>(
    taggedWith tag: Tag,
    sortedBy sortingKeyPath: KeyPath<Item<Site>, T>,
    order: SortOrder = .ascending
  ) -> [Item<Site>] {
    items(taggedWith: tag).sorted(
      by: order.makeSorter(forKeyPath: sortingKeyPath)
    )
  }

  /// Add an item to the website programmatically.
  /// - parameter item: The item to add.
  public mutating func addItem(_ item: Item<Site>) {
    sections[item.sectionID].addItem(item)
  }

  /// Add a page to the website programmatically.
  /// - parameter page: The page to add.
  public mutating func addPage(_ page: Page) {
    pages[page.path] = page
  }

  /// Mutate all of the website's sections using a closure.
  /// - parameter mutations: The mutations to apply to each section.
  public mutating func mutateAllSections(using mutations: Mutations<Section<Site>>) rethrows {
    for id in sections.ids {
      try mutations(&sections[id])
    }
  }

  /// Mutate one of the website's existing pages.
  /// - Parameters:
  ///   - path: The path of the page to mutate.
  ///   - predicate: Any predicate to match against before mutating the page.
  ///   - mutations: The mutations to apply to the page.
  /// - throws: An error in case the page couldn't be found, or
  ///   if the mutation close itself threw an error.
  public mutating func mutatePage(
    at path: Path,
    matching predicate: Predicate<Page> = .any,
    using mutations: Mutations<Page>
  ) throws {
    guard var page = pages[path] else {
      throw ContentError(path: path, reason: .pageNotFound)
    }

    guard predicate.matches(page) else {
      return
    }

    do {
      try mutations(&page)
      pages[page.path] = page

      if page.path != path {
        pages[path] = nil
      }
    } catch {
      throw ContentError(
        path: page.path,
        reason: .pageMutationFailed(error)
      )
    }
  }
}
