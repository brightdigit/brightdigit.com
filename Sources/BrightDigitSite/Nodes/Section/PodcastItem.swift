import Foundation
import Plot
import Publish
import PublishType

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct PodcastItem: SectionItem {
  typealias WebsiteType = BrightDigitSite
  var redirectURL: URL? {
    nil
  }

  static let sectionH1: String? = sectionTitle

  static let sectionTitle: String = "EmpowerApps Podcast"

  static let sectionDescription: String = "Watch and Listen to the latest episodes of EmpowerApps Show, we talk all things app development and Apple"

  let description: String
  let episodeNo: Int
  let title: String
  let publishedDate: Date
  let youtubeID: String?
  let audioDuration: TimeInterval
  let videoDuration: TimeInterval?
  let featuredImageURL: URL
  let isFeatured: Bool
  let transistorID: String
  let source: Item<BrightDigitSite>
  let site: WebsiteType

  var pageTitle: String {
    title
  }

  var pageBodyID: String? {
    nil
  }

  init(item: Item<BrightDigitSite>, site: BrightDigitSite) throws {
    source = item
    self.site = site
    let featuredImageURL = item.featuredImageURL
    let isFeatured = item.metadata.featured ?? false

    let episodeNo = item.path.absoluteString.components(separatedBy: "/").last?.components(separatedBy: .decimalDigits.inverted).first.flatMap(Int.init)

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
