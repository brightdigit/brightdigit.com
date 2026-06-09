import Foundation
import Plot
import Publish
import PublishType

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension PodcastItem {
  static let youtubeImageBaseURL = URL(staticString: "https://i.ytimg.com/vi/")

  static let maxresdefault = "maxresdefault.jpg"

  static let transistorShareBaseURL: URL = Self.transistorBaseURL.appendingPathComponent("s")
  static let transistorEmbedBaseURL: URL = Self.transistorBaseURL.appendingPathComponent("e")
  static let transistorBaseURL: URL = .init(staticString: "https://share.transistor.fm/")

  static let youtubeBaseURL: URL = .init(staticString: "https://www.youtube.com/")
  static let youtubeEmbedBaseURL = Self.youtubeBaseURL.appendingPathComponent("embed")
  static let youtubeShareBaseURLComponents: URLComponents = {
    guard let components = URLComponents(
      url: Self.youtubeBaseURL.appendingPathComponent("watch"),
      resolvingAgainstBaseURL: false
    ) else {
      preconditionFailure("Invalid YouTube share base URL")
    }
    return components
  }()

  var imageURL: URL {
    guard let youtubeID = youtubeID, episodeNo > 86 else {
      return featuredImageURL
    }
    return Self.youtubeImageBaseURL.appendingPathComponent(youtubeID).appendingPathComponent(Self.maxresdefault)
  }

  var transistorEmbedURL: URL {
    Self.transistorEmbedBaseURL.appendingPathComponent(transistorID)
  }

  var youtubeEmbedURL: URL? {
    youtubeID.map(Self.youtubeEmbedBaseURL.appendingPathComponent)
  }

  var transistorShareURL: URL {
    Self.transistorShareBaseURL.appendingPathComponent(transistorID)
  }

  var youtubeShareURL: URL? {
    guard let youtubeID = youtubeID else {
      return nil
    }

    var urlComponents = Self.youtubeShareBaseURLComponents
    urlComponents.queryItems = [URLQueryItem(name: "v", value: youtubeID)]
    return urlComponents.url
  }

  var youtubeEmbed: Node<HTML.BodyContext>? {
    youtubeEmbedURL.map { youtubeEmbedURL in
      .iframe(
        .src(youtubeEmbedURL),
        .frameborder(false),
        .allowfullscreen(true),
        .allow("accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture")
      )
    }
  }

  var transistorEmbed: Node<HTML.BodyContext> {
    .iframe(
      .attribute(named: "width", value: "100%"),
      .attribute(named: "height", value: "180"),
      .frameborder(false),
      .attribute(named: "scrolling", value: "no"),
      .attribute(named: "seamless", value: nil),
      .src(transistorEmbedURL)
    )
  }
}
