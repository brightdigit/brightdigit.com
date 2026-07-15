/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Publish
import Plot

// Test website doubles, modeled as Sendable value types (no @unchecked). The
// configuration properties remain mutable `var`s so tests can tweak them during
// setup; being a struct keeps the whole thing Sendable.
enum WebsiteStub {
    enum SectionID: String, WebsiteSectionID {
        case one, two, three, customRawValue = "custom-raw-value"
    }

    struct EmptyItemMetadata: WebsiteItemMetadata {}

    struct PodcastItemMetadata: PodcastCompatibleWebsiteItemMetadata {
        var podcast: PodcastEpisodeMetadata?
    }

    struct Site<ItemMetadata: WebsiteItemMetadata>: Website {
        typealias SectionID = WebsiteStub.SectionID

        var url = URL(string: "https://swiftbysundell.com")!
        var name = "WebsiteName"
        var description = "Description"
        var language = Language.english
        var imagePath: Path? = nil
        var faviconPath: Path? = nil
        var tagHTMLConfig: TagHTMLConfiguration? = .default

        init() {}

        func title(for sectionID: SectionID) -> String {
            sectionID.rawValue
        }
    }

    typealias WithoutItemMetadata = Site<EmptyItemMetadata>
    typealias WithPodcastMetadata = Site<PodcastItemMetadata>
    typealias WithItemMetadata<ItemMetadata: WebsiteItemMetadata> = Site<ItemMetadata>
}
