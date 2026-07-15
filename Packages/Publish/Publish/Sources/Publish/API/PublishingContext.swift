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

/// Type that represents the context in which a website is being published.
/// It can be used to manipulate the state of the website in various ways,
/// including mutating and adding new content, creating new files and folders,
/// and so on. Each `PublishingStep` gets access to the current context.
public struct PublishingContext<Site: Website>: Sendable {
  /// The `Date.FormatString` that Publish uses by default when parsing dates
  /// from Markdown front matter (equivalent to `"yyyy-MM-dd HH:mm"`).
  public static var defaultDateFormat: Date.FormatString {
    // A single `Date.FormatString` interpolation that cannot be split across
    // lines without changing its type or value.
    // swiftlint:disable:next line_length
    "\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)"
  }

  /// The website that this context is for.
  public let site: Site
  /// The Markdown parser that this publishing session is using. You can
  /// add modifiers to it to customize how each Markdown string is rendered.
  public var markdownParser = MarkdownParser()
  /// The parse strategy that this publishing session is using when parsing
  /// dates from Markdown files. Replaces the previous `DateFormatter`-based
  /// API so that the context can be fully `Sendable`.
  public var dateParseStrategy: Date.ParseStrategy
  /// A representation of the website's main index page.
  public var index = Index()
  /// The sections that the website contains.
  public var sections = SectionMap<Site>() { didSet { tagCache.tags = nil } }
  /// The free-form pages that the website contains.
  public internal(set) var pages = [Path: Page]()
  /// A set containing all tags that are currently being used website-wide.
  public var allTags: Set<Tag> { tagCache.tags ?? gatherAllTags() }
  /// Any date when the website was last generated.
  public private(set) var lastGenerationDate: Date?

  internal let folders: Folder.Group
  private let tagCache = TagCache()
  internal var stepName: String

  internal init(
    site: Site,
    folders: Folder.Group,
    firstStepName: String
  ) {
    self.site = site
    self.folders = folders
    self.stepName = firstStepName
    self.dateParseStrategy = Date.ParseStrategy(
      format: Self.defaultDateFormat,
      locale: .current,
      timeZone: .current
    )
  }
}

extension PublishingContext {
  internal mutating func generationWillBegin() {
    try? updateLastGenerationDate()
  }

  internal mutating func prepareForStep(named name: String) {
    stepName = name
  }

  internal func makeMarkdownContentFactory() -> MarkdownContentFactory<Site> {
    MarkdownContentFactory(
      parser: markdownParser,
      dateParseStrategy: dateParseStrategy
    )
  }

  internal func copyFileToOutput(
    _ file: File,
    targetFolderPath: Path?
  ) throws {
    try copyLocationToOutput(
      file,
      targetFolderPath: targetFolderPath,
      errorReason: .fileCopyingFailed
    )
  }

  internal func copyFolderToOutput(
    _ folder: Folder,
    targetFolderPath: Path?
  ) throws {
    try copyLocationToOutput(
      folder,
      targetFolderPath: targetFolderPath,
      errorReason: .folderCopyingFailed
    )
  }
}

extension PublishingContext {
  /// A `Sendable` cache for the website-wide tag set, backed by a Mutex so
  /// that the synchronous `allTags` getter is preserved while keeping
  /// `PublishingContext` `Sendable` (rather than turning `allTags` async via
  /// an actor).
  fileprivate final class TagCache: Sendable {
    private let storage = Mutex<Set<Tag>?>(nil)

    var tags: Set<Tag>? {
      get { storage.withLock { $0 } }
      set { storage.withLock { $0 = newValue } }
    }
  }

  fileprivate mutating func updateLastGenerationDate() throws {
    let fileName = "lastGenerationDate"
    let newString = String(Date().timeIntervalSince1970)

    if let file = try? folders.internal.file(named: fileName) {
      let oldInterval = try TimeInterval(file.readAsString())

      lastGenerationDate = oldInterval.map {
        Date(timeIntervalSince1970: $0)
      }

      try file.write(newString)
    } else {
      let file = try folders.internal.createFile(named: fileName)
      try file.write(newString)
    }
  }

  fileprivate func gatherAllTags() -> Set<Tag> {
    var tags = Set<Tag>()

    for section in sections {
      tags.formUnion(section.allTags)
    }

    tagCache.tags = tags
    return tags
  }

  fileprivate func copyLocationToOutput<T: Files.Location>(
    _ location: T,
    targetFolderPath: Path?,
    errorReason: FileIOError.Reason
  ) throws {
    let targetFolder = try targetFolderPath.map {
      try createOutputFolder(at: $0)
    }

    do {
      try location.copy(to: targetFolder ?? folders.output)
    } catch {
      let path = Path(location.path(relativeTo: folders.root))
      throw FileIOError(path: path, reason: errorReason)
    }
  }

  internal func createFolder(at path: Path, in folder: Folder) throws(FileIOError) -> Folder {
    do {
      return try folder.createSubfolderIfNeeded(at: path.string)
    } catch {
      let path = Path(folder.path + path.string)
      throw FileIOError(path: path, reason: .folderCreationFailed)
    }
  }

  internal func createFile(at path: Path, in folder: Folder) throws(FileIOError) -> File {
    do {
      return try folder.createFileIfNeeded(at: path.string)
    } catch {
      let path = Path(folder.path + path.string)
      throw FileIOError(path: path, reason: .fileCreationFailed)
    }
  }
}
