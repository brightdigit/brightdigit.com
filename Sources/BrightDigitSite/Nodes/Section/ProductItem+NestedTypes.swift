import Foundation
import Plot
import Publish
import PublishType

extension ProductItem {
  enum ScreenshotStyle: String, Codable, Equatable {
    case `default`, portrait, square
  }

    struct PressCoverage: Codable, Equatable, Hashable {
      internal init(source: String, quote: String, url: String, date: Date) {
        self.source = source
        self.quote = quote
        guard let parsedURL = URL(string: url) else {
          preconditionFailure("Invalid PressCoverage URL: \(url)")
        }
        self.url = parsedURL
        self.date = date
      }

      let source: String
      let quote: String
      let url: URL
      let date: Date
    }

  struct Image {
    fileprivate init(path: String) {
      self.path = path
    }


    static func logo(withName name: String?) -> Image {
      at(path: name ?? "logo.svg")
    }

    static func at(path: String) -> Image {
      self.init(path: path)
    }

    static let basePath = "/media/products"
    let path: String

    func string(basedOnSlug slug: String) -> String {
      [Self.basePath, slug, path].joined(separator: "/")
    }
  }
}
