/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Publish
import Plot

// This is a test double whose configuration properties are only ever mutated
// during a test's synchronous setup, before it is handed to the (sequential)
// publishing pipeline. That external synchronization makes the unchecked
// Sendable conformance sound; the non-final class hierarchy rules out a
// checked conformance.
class WebsiteStub: @unchecked Sendable {
    enum SectionID: String, WebsiteSectionID {
        case one, two, three, customRawValue = "custom-raw-value"
    }

    var url = URL(string: "https://swiftbysundell.com")!
    var name = "WebsiteName"
    var description = "Description"
    var language = Language.english
    var imagePath: Path? = nil
    var faviconPath: Path? = nil
    var tagHTMLConfig: TagHTMLConfiguration? = .default

    required init() {}

    func title(for sectionID: WebsiteStub.SectionID) -> String {
        sectionID.rawValue
    }
}

extension WebsiteStub {
    final class WithItemMetadata<ItemMetadata: WebsiteItemMetadata>: WebsiteStub, Website, @unchecked Sendable {}

    final class WithPodcastMetadata: WebsiteStub, Website, @unchecked Sendable {
        struct ItemMetadata: PodcastCompatibleWebsiteItemMetadata {
            var podcast: PodcastEpisodeMetadata?
        }
    }

    final class WithoutItemMetadata: WebsiteStub, Website, @unchecked Sendable {
        struct ItemMetadata: WebsiteItemMetadata {}
    }
}
