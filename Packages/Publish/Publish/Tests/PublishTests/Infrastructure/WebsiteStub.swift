/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Plot
import Publish

// Test website doubles, modeled as Sendable value types (no @unchecked). The
// configuration properties remain mutable `var`s so tests can tweak them during
// setup; being a struct keeps the whole thing Sendable.
internal enum WebsiteStub {
  internal typealias WithoutItemMetadata = Site<EmptyItemMetadata>
  internal typealias WithPodcastMetadata = Site<PodcastItemMetadata>
  internal typealias WithItemMetadata<ItemMetadata: WebsiteItemMetadata> = Site<ItemMetadata>

  internal enum SectionID: String, WebsiteSectionID {
    case one, two, three
    case customRawValue = "custom-raw-value"
  }

  internal struct EmptyItemMetadata: WebsiteItemMetadata {}

  internal struct PodcastItemMetadata: PodcastCompatibleWebsiteItemMetadata {
    internal var podcast: PodcastEpisodeMetadata?
  }

  internal struct Site<ItemMetadata: WebsiteItemMetadata>: Website {
    internal typealias SectionID = WebsiteStub.SectionID

    // A hard-coded, always-valid literal URL for the test stub website.
    // swift-format-ignore: NeverForceUnwrap
    // swiftlint:disable:next force_unwrapping
    internal var url = URL(string: "https://swiftbysundell.com")!
    internal var name = "WebsiteName"
    internal var description = "Description"
    internal var language = Language.english
    internal var imagePath: Path?
    internal var tagHTMLConfig: TagHTMLConfiguration? = .default

    internal init() {}
  }
}
