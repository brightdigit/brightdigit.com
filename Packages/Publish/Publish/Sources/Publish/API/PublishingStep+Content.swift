/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Foundation
import Plot

// MARK: - Content

extension PublishingStep {
  /// Add an item to website programmatically.
  /// - parameter item: The item to add.
  /// - Returns: The configured publishing step.
  public static func addItem(_ item: Item<Site>) -> Self {
    step(named: "Add item '\(item.path)'") { context in
      context.addItem(item)
    }
  }

  /// Add a sequence of items to website programmatically.
  /// - parameter sequence: The items to add.
  /// - Returns: The configured publishing step.
  public static func addItems<S: Sequence & Sendable>(
    in sequence: S
  ) -> Self where S.Element == Item<Site> {
    step(named: "Add items in sequence") { context in
      for item in sequence {
        context.addItem(item)
      }
    }
  }

  /// Add a page to website programmatically.
  /// - parameter page: The page to add.
  /// - Returns: The configured publishing step.
  public static func addPage(_ page: Page) -> Self {
    step(named: "Add page '\(page.path)'") { context in
      context.addPage(page)
    }
  }

  /// Add a sequence of pages to website programmatically.
  /// - parameter sequence: The pages to add.
  /// - Returns: The configured publishing step.
  public static func addPages<S: Sequence & Sendable>(
    in sequence: S
  ) -> Self where S.Element == Page {
    step(named: "Add pages in sequence") { context in
      for page in sequence {
        context.addPage(page)
      }
    }
  }

  /// Parse a folder of Markdown files and use them to add content to
  /// the website. The root folders will be parsed as sections, and the
  /// files within them as items, while root files will be parsed as pages.
  /// - Returns: The configured publishing step.
  /// - parameter path: The path of the Markdown folder to add (default: `Content`).
  public static func addMarkdownFiles(at path: Path = "Content") -> Self {
    step(named: "Add Markdown files from '\(path)' folder") { context in
      let folder = try context.folder(at: path)
      try await MarkdownFileHandler().addMarkdownFiles(in: folder, to: &context)
    }
  }

  /// Remove all items matching a predicate, optionally within a specific section.
  /// - Parameters:
  ///   - section: Any specific section to remove all items within.
  ///   - predicate: Any predicate to filter the items using.
  /// - Returns: The configured publishing step.
  public static func removeAllItems(
    in section: Site.SectionID? = nil,
    matching predicate: Predicate<Item<Site>> = .any
  ) -> Self {
    let nameSuffix = section.map { " in '\($0)'" } ?? ""

    return step(named: "Remove items" + nameSuffix) { context in
      if let section = section {
        context.sections[section].removeItems(matching: predicate)
      } else {
        for section in context.sections.ids {
          context.sections[section].removeItems(matching: predicate)
        }
      }
    }
  }
}
