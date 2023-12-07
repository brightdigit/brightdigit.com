import Foundation
import Plot
import Publish
import PublishType

struct ProductItem: SectionItem {
  typealias WebsiteType = BrightDigitSite

  enum ScreenshotStyle: String, Codable, Equatable {
    case `default`, portrait, square
  }
  
    struct PressCoverage: Codable, Equatable, Hashable {
      internal init(source: String, quote: String, url: String, date: Date) {
        self.source = source
        self.quote = quote
        self.url = URL(string: url)!
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

  let title: String
  let description: String

  var logo: String
  let style: ScreenshotStyle
  let screenshots: [String]
  let platforms: [String]
  let technologies: [String]

  let date: Date

  let productURL: URL
  let githubURL: URL?
  let pressKitURL: URL?
  let appStoreURL: URL?

  var featuredItemContent: Plot.Node<Plot.HTML.BodyContext> {
    SectionElement{
      List{
        ListItem(forProduct: self)
      }
    }.environmentValue(.ordered, key: .listStyle).convertToNode()
  }

  var sectionItemContent: [Plot.Node<Plot.HTML.BodyContext>] {
    [SectionElement(forProduct: self).environmentValue(.ordered, key: .listStyle).convertToNode()]
  }

  let source: Item<BrightDigitSite>

  let isFeatured: Bool

  static let sectionH1: String? = "Products"

  static let sectionTitle: String = "Products"

  static let sectionDescription: String = "Here are some of the apps and libraries we’ve created. Like what you see? Contact us to find out if we can help you reach your app goals."

  var pageTitle: String {
    title
  }

  var pageBodyID: String? {
    nil
  }

  var pageMainContent: [Plot.Node<Plot.HTML.BodyContext>] {
    [.contentBody(source.body)]
  }

  var redirectURL: URL? {
    nil
  }

  var featuredImageURL: URL { URL(staticString: logo) }

  init(item: Item<BrightDigitSite>, site: BrightDigitSite) throws {
    let platforms = item.metadata.platforms?
      .components(separatedBy: ",")
      .map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}

    guard let platforms = platforms else {
      throw PublishTypeError.missingField(
        MissingFields.ProductField.platforms,
        item
      )
    }

    let technologies = item.metadata.technologies?
      .components(separatedBy: ",")
      .map{
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
      }
      

    guard let technologies = technologies else {
      throw PublishTypeError.missingField(
        MissingFields.ProductField.technologies,
        item
      )
    }

    let slug = item.title.convertedToSlug()
    let logo = item.metadata.featuredImage
      
    let style: ScreenshotStyle = {
      guard let rawValue = item.metadata.style else {
        return .default
      }
      return .init(rawValue: rawValue) ?? .default
    }()
    let screenshots = item.metadata.screenshots?
      .map { Image(path: $0).string(basedOnSlug: slug) } ?? []
    let productURL = try Self.calculateProductURL(from: item)
    let githubURL = Self.buildGithubURL(from: item.metadata.githubRepoName)

    self.source = item
    self.isFeatured = item.metadata.isFeatured ?? false
    self.appStoreURL = item.metadata.appStoreURL.map(URL.init(staticString:))
    self.pressKitURL = item.metadata.pressKitURL.map(URL.init(staticString:))
    self.title = item.title
    self.description = item.description
    self.date = item.metadata.date
    self.logo = logo
    self.style = style
    self.screenshots = screenshots
    self.platforms = platforms
    self.technologies = technologies
    self.productURL = productURL
    self.githubURL = githubURL
  }

  private static func calculateProductURL(
    from item: Item<BrightDigitSite>) throws -> URL {
      if let productURL = item.metadata.productURL {
        return URL(staticString: productURL)
      }

      guard let productURL = buildGithubURL(from: item.metadata.githubRepoName) else {
        throw PublishTypeError.missingField(
          MissingFields.ProductField.productURL,
          item
        )
      }

      return productURL
  }

  private static func buildGithubURL(from repoName: String?) -> URL? {
    repoName
      .map { "https://github.com/BrightDigit/" + $0 }
      .map { URL(staticString: $0) }
  }
}
