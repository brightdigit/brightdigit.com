/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// A map type containing all sections within a given website.
/// You access an instance of this type through the current `PublishingContext`.
public struct SectionMap<Site: Website>: Sendable {
  /// The IDs of all the sections contained within this map, in the order
  /// they were defined within the site's `SectionID` enum.
  public var ids: Site.SectionID.AllCases { Site.SectionID.allCases }
  private var sections = [Site.SectionID: Section<Site>]()

  internal init() {
    for id in Site.SectionID.allCases {
      sections[id] = Section(id: id)
    }
  }

  /// Access the section associated with a given ID.
  /// - parameter id: The ID of the section to access.
  public subscript(id: Site.SectionID) -> Section<Site> {
    get {
      // `sections` is populated with every `SectionID` case in `init`,
      // so a lookup by any valid section ID always succeeds.
      guard let section = sections[id] else {
        preconditionFailure("Missing section for id \(id)")
      }
      return section
    }
    set { sections[newValue.id] = newValue }
  }
}

extension SectionMap: Sequence {
  /// Create an iterator over the sections contained in this map.
  public func makeIterator() -> AnyIterator<Section<Site>> {
    var ids = self.ids.makeIterator()

    return AnyIterator {
      guard let nextID = ids.next() else {
        return nil
      }
      return self[nextID]
    }
  }
}
