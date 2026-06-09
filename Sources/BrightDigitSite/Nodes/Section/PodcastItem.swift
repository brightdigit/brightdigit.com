import Foundation
import Plot
import Publish
import PublishType

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal struct PodcastItem: SectionItem {
  internal typealias WebsiteType = BrightDigitSite

  internal static let sectionH1: String? = sectionTitle

  internal static let sectionTitle: String = "EmpowerApps Podcast"

  internal static let sectionDescription: String =
    "Watch and Listen to the latest episodes of EmpowerApps Show, we talk all things app development and Apple"

  internal let description: String
  internal let episodeNo: Int
  internal let title: String
  internal let publishedDate: Date
  internal let youtubeID: String?
  internal let audioDuration: TimeInterval
  internal let videoDuration: TimeInterval?
  internal let featuredImageURL: URL
  internal let isFeatured: Bool
  internal let transistorID: String
  internal let source: Item<BrightDigitSite>
  internal let site: WebsiteType

  internal var redirectURL: URL? {
    nil
  }

  internal var pageTitle: String {
    title
  }

  internal var pageBodyID: String? {
    nil
  }

  internal init(item: Item<BrightDigitSite>, site: BrightDigitSite) throws {
    source = item
    self.site = site
    let featuredImageURL = item.featuredImageURL
    let isFeatured = item.metadata.featured ?? false

    let episodeNo = item.path.absoluteString.components(separatedBy: "/").last?
      .components(separatedBy: .decimalDigits.inverted).first.flatMap(Int.init)

    guard let episodeNo = episodeNo else {
      throw PublishTypeError.missingField(MissingFields.PodcastField.episodeNo, item)
    }

    guard let audioDuration = item.metadata.audioDuration else {
      throw PublishTypeError.missingField(MissingFields.PodcastField.audioDuration, item)
    }

    guard let transistorID = item.metadata.podcastID else {
      throw PublishTypeError.missingField(MissingFields.PodcastField.transistorID, item)
    }

    title = item.title
    description = item.description
    self.featuredImageURL = featuredImageURL
    publishedDate = item.metadata.date
    self.episodeNo = episodeNo
    self.audioDuration = audioDuration
    videoDuration = item.metadata.videoDuration
    youtubeID = item.metadata.youtubeID
    self.isFeatured = isFeatured
    self.transistorID = transistorID
  }
}
