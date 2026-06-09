import Foundation
import Plot
import Publish
import PublishType

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension PodcastItem {
  internal static let youtubeImageBaseURL = URL(staticString: "https://i.ytimg.com/vi/")

  internal static let maxresdefault = "maxresdefault.jpg"

  internal static let transistorShareBaseURL: URL = Self.transistorBaseURL
    .appendingPathComponent(
      "s")
  internal static let transistorEmbedBaseURL: URL = Self.transistorBaseURL
    .appendingPathComponent(
      "e")
  internal static let transistorBaseURL: URL = .init(
    staticString: "https://share.transistor.fm/")

  internal static let youtubeBaseURL: URL = .init(
    staticString: "https://www.youtube.com/")
  internal static let youtubeEmbedBaseURL = Self.youtubeBaseURL.appendingPathComponent(
    "embed")
  internal static let youtubeShareBaseURLComponents: URLComponents = {
    guard
      let components = URLComponents(
        url: Self.youtubeBaseURL.appendingPathComponent("watch"),
        resolvingAgainstBaseURL: false
      )
    else {
      preconditionFailure("Invalid YouTube share base URL")
    }
    return components
  }()

  internal var imageURL: URL {
    guard let youtubeID = youtubeID, episodeNo > 86 else {
      return featuredImageURL
    }
    return Self.youtubeImageBaseURL.appendingPathComponent(youtubeID)
      .appendingPathComponent(Self.maxresdefault)
  }

  internal var transistorEmbedURL: URL {
    Self.transistorEmbedBaseURL.appendingPathComponent(transistorID)
  }

  internal var youtubeEmbedURL: URL? {
    youtubeID.map(Self.youtubeEmbedBaseURL.appendingPathComponent)
  }

  internal var transistorShareURL: URL {
    Self.transistorShareBaseURL.appendingPathComponent(transistorID)
  }

  internal var youtubeShareURL: URL? {
    guard let youtubeID = youtubeID else {
      return nil
    }

    var urlComponents = Self.youtubeShareBaseURLComponents
    urlComponents.queryItems = [URLQueryItem(name: "v", value: youtubeID)]
    return urlComponents.url
  }

  internal var youtubeEmbed: Node<HTML.BodyContext>? {
    youtubeEmbedURL.map { youtubeEmbedURL in
      .iframe(
        .src(youtubeEmbedURL),
        .frameborder(false),
        .allowfullscreen(true),
        .allow(
          "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        )
      )
    }
  }

  internal var transistorEmbed: Node<HTML.BodyContext> {
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
