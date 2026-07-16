/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Foundation
import Plot

extension PublishingStep {
  /// Mutate all items matching a predicate, optionally within a specific section.
  /// - Parameters:
  ///   - section: Any specific section to mutate all items within.
  ///   - predicate: Any predicate to filter the items using.
  ///   - mutations: The mutations to apply to each item.
  /// - Returns: The configured publishing step.
  public static func mutateAllItems(
    in section: Site.SectionID? = nil,
    matching predicate: Predicate<Item<Site>> = .any,
    using mutations: @escaping Mutations<Item<Site>>
  ) -> Self {
    mutateAllItems(
      in: section.map { [$0] } ?? Set(Site.SectionID.allCases),
      matching: predicate,
      using: mutations
    )
  }

  /// Mutate all items matching a predicate within a certain set of sections.
  /// - Parameters:
  ///   - sections: The sections to mutate all items within.
  ///   - predicate: Any predicate to filter the items using.
  ///   - mutations: The mutations to apply to each item.
  /// - Returns: The configured publishing step.
  public static func mutateAllItems(
    in sections: Set<Site.SectionID>,
    matching predicate: Predicate<Item<Site>> = .any,
    using mutations: @escaping Mutations<Item<Site>>
  ) -> Self {
    var stepName = "Mutate all items"

    if sections.count != Site.SectionID.allCases.count {
      let sectionDescription =
        sections
        .map(\.rawValue)
        .joined(separator: ", ")

      stepName.append(" in \(sectionDescription)")
    }

    return step(named: stepName) { context in
      for section in sections {
        try context.sections[section].replaceItems(
          with: context.sections[section].items.map { item in
            guard predicate.matches(item) else {
              return item
            }

            do {
              var item = item
              try mutations(&item)
              return item
            } catch {
              throw ContentError(
                path: item.path,
                reason: .itemMutationFailed(error)
              )
            }
          }
        )
      }
    }
  }

  /// Mutate an item at a given path within a section.
  /// - Parameters:
  ///   - path: The relative path of the item to mutate.
  ///   - section: The section that the item belongs to.
  ///   - mutations: The mutations to apply to the item.
  /// - Returns: The configured publishing step.
  public static func mutateItem(
    at path: Path,
    in section: Site.SectionID,
    using mutations: @escaping Mutations<Item<Site>>
  ) -> Self {
    step(named: "Mutate item at '\(path)' in \(section)") { context in
      try context.sections[section].mutateItem(at: path, using: mutations)
    }
  }

  /// Mutate a page at a given path.
  /// - Parameters:
  ///   - path: The path of the page to mutate.
  ///   - mutations: The mutations to apply to the page.
  /// - Returns: The configured publishing step.
  public static func mutatePage(
    at path: Path,
    using mutations: @escaping Mutations<Page>
  ) -> Self {
    step(named: "Mutate page at '\(path)'") { context in
      try context.mutatePage(at: path, using: mutations)
    }
  }

  /// Mutate all pages, optionally matching a given predicate.
  /// - Parameters:
  ///   - predicate: Any predicate to filter the items using.
  ///   - mutations: The mutations to apply to the page.
  /// - Returns: The configured publishing step.
  public static func mutateAllPages(
    matching predicate: Predicate<Page> = .any,
    using mutations: @escaping Mutations<Page>
  ) -> Self {
    step(named: "Mutate all pages") { context in
      for path in context.pages.keys {
        try context.mutatePage(
          at: path,
          matching: predicate,
          using: mutations
        )
      }
    }
  }

  /// Sort all items, optionally within a specific section, using a key path.
  /// - Parameters:
  ///   - section: Any specific section to sort all items within.
  ///   - keyPath: The key path to use when sorting.
  ///   - order: The order to use when sorting.
  /// - Returns: The configured publishing step.
  public static func sortItems<T: Comparable & Sendable>(
    in section: Site.SectionID? = nil,
    by keyPath: KeyPath<Item<Site>, T> & Sendable,
    order: SortOrder = .ascending
  ) -> Self {
    let nameSuffix = section.map { " in '\($0)'" } ?? ""

    return step(named: "Sort items" + nameSuffix) { context in
      let sorter = order.makeSorter(forKeyPath: keyPath)

      if let section = section {
        context.sections[section].sortItems(by: sorter)
      } else {
        for section in context.sections {
          context.sections[section.id].sortItems(by: sorter)
        }
      }
    }
  }
}
