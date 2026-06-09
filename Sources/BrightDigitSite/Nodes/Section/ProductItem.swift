import Foundation
import Plot
import Publish
import PublishType

internal struct ProductItem: SectionItem {
  internal typealias WebsiteType = BrightDigitSite

  private struct ParsedMetadata {
    fileprivate let platforms: [String]
    fileprivate let technologies: [String]
    fileprivate let slug: String
    fileprivate let logo: String
    fileprivate let style: ScreenshotStyle
    fileprivate let screenshots: [String]
    fileprivate let productURL: URL
    fileprivate let githubURL: URL?
  }

  internal static let sectionH1: String? = "Products"

  internal static let sectionTitle: String = "Products"

  internal static let sectionDescription: String =
    "Here are some of the apps and libraries we’ve created. Like what you see? Contact us to find out if we can help you reach your app goals."

  internal let title: String
  internal let description: String

  internal var logo: String
  internal let style: ScreenshotStyle
  internal let screenshots: [String]
  internal let platforms: [String]
  internal let technologies: [String]

  internal let date: Date

  internal let productURL: URL
  internal let githubURL: URL?
  internal let pressKitURL: URL?
  internal let appStoreURL: URL?

  internal let source: Item<BrightDigitSite>

  internal let isFeatured: Bool
  internal let clipLogo: Bool

  internal var pageTitle: String {
    title
  }

  internal var pageBodyID: String? {
    nil
  }

  internal var pageMainContent: [Plot.Node<Plot.HTML.BodyContext>] {
    [.contentBody(source.body)]
  }

  internal var redirectURL: URL? {
    self.productURL
  }

  internal var featuredImageURL: URL { URL(staticString: logo) }

  internal init(item: Item<BrightDigitSite>, site: BrightDigitSite) throws {
    let parsed = try Self.parseMetadata(from: item)

    self.source = item
    self.isFeatured = item.metadata.isFeatured ?? false
    self.clipLogo = item.metadata.clipLogo ?? true
    self.appStoreURL = item.metadata.appStoreURL.map(URL.init(staticString:))
    self.pressKitURL = item.metadata.pressKitURL.map(URL.init(staticString:))
    self.title = item.title
    self.description = item.description
    self.date = item.metadata.date
    self.logo = parsed.logo
    self.style = parsed.style
    self.screenshots = parsed.screenshots
    self.platforms = parsed.platforms
    self.technologies = parsed.technologies
    self.productURL = parsed.productURL
    self.githubURL = parsed.githubURL
  }

  private static func commaSeparated(
    _ raw: String?,
    or field: MissingFields.ProductField,
    _ item: Item<BrightDigitSite>
  ) throws -> [String] {
    guard let raw else {
      throw PublishTypeError.missingField(field, item)
    }
    return raw.components(separatedBy: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
  }

  private static func parseMetadata(from item: Item<BrightDigitSite>) throws
    -> ParsedMetadata
  {
    let platforms = try Self.commaSeparated(item.metadata.platforms, or: .platforms, item)
    let technologies = try Self.commaSeparated(
      item.metadata.technologies, or: .technologies, item
    )

    let slug = item.title.convertedToSlug()
    let logo = item.metadata.featuredImage

    let style: ScreenshotStyle = {
      guard let rawValue = item.metadata.style else {
        return .default
      }
      return .init(rawValue: rawValue) ?? .default
    }()
    let screenshots =
      item.metadata.screenshots?
      .map { Image.at(path: $0).string(basedOnSlug: slug) } ?? []
    let productURL = try Self.calculateProductURL(from: item)
    let githubURL = Self.buildGithubURL(from: item.metadata.githubRepoName)

    return ParsedMetadata(
      platforms: platforms,
      technologies: technologies,
      slug: slug,
      logo: logo,
      style: style,
      screenshots: screenshots,
      productURL: productURL,
      githubURL: githubURL
    )
  }

  private static func calculateProductURL(
    from item: Item<BrightDigitSite>
  ) throws -> URL {
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
