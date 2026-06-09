import Foundation
import Plot
import Publish
import PublishType

extension ProductItem {
  internal enum ScreenshotStyle: String, Codable, Equatable {
    case `default`, portrait, square
  }

  internal struct PressCoverage: Codable, Equatable, Hashable {
    internal let source: String
    internal let quote: String
    internal let url: URL
    internal let date: Date

    internal init(source: String, quote: String, url: String, date: Date) {
      self.source = source
      self.quote = quote
      guard let parsedURL = URL(string: url) else {
        preconditionFailure("Invalid PressCoverage URL: \(url)")
      }
      self.url = parsedURL
      self.date = date
    }
  }

  internal struct Image {
    internal static let basePath = "/media/products"
    internal let path: String

    fileprivate init(path: String) {
      self.path = path
    }

    internal static func logo(withName name: String?) -> Image {
      at(path: name ?? "logo.svg")
    }

    internal static func at(path: String) -> Image {
      self.init(path: path)
    }

    internal func string(basedOnSlug slug: String) -> String {
      [Self.basePath, slug, path].joined(separator: "/")
    }
  }
}
