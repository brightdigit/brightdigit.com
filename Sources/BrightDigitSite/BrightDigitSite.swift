import Foundation
import NPMPublishPlugin
import Plot
import Publish
import PublishType
import ReadingTimePublishPlugin
import SplashPublishPlugin
import TransistorPublishPlugin
import YoutubePublishPlugin

func copyDirectory(from sourcePath: String, to destinationPath: String) throws {
    let fileManager = FileManager.default
    
    // Check if source directory exists
    var isDirectory: ObjCBool = false
    guard fileManager.fileExists(atPath: sourcePath, isDirectory: &isDirectory), isDirectory.boolValue else {
        throw NSError(domain: "DirectoryCopyError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Source path is not a directory or doesn't exist."])
    }
    
    // Create destination directory if it doesn't exist
    if !fileManager.fileExists(atPath: destinationPath) {
        try fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true)
    }
    
    // Get contents of the source directory
    let contents = try fileManager.contentsOfDirectory(atPath: sourcePath)
    
    // Copy each item in the directory
    for item in contents {
        let sourceItemPath = (sourcePath as NSString).appendingPathComponent(item)
        let destinationItemPath = (destinationPath as NSString).appendingPathComponent(item)
        
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: sourceItemPath, isDirectory: &isDir) {
            if isDir.boolValue {
                // Recursively copy subdirectories
                try copyDirectory(from: sourceItemPath, to: destinationItemPath)
            } else {
                // Copy files
              try fileManager.copyItem(atPath: sourceItemPath, toPath: destinationItemPath)
            }
        }
    }
}

func copyResourcesStep() -> PublishingStep<BrightDigitSite> {
  .step(named: "Copy Resources") { context in
    let sourcePath = try context.folder(at: "Resources").path
    let destinationPath = try context.outputFolder(at: "").path
   try  copyDirectory(from: sourcePath, to: destinationPath)
  }
}

// This type acts as the configuration for your website.
public struct BrightDigitSite: Website, MetadataAttached {
  public init(imagePath: Path? = SiteInfo.imagePath) {
    self.imagePath = imagePath
  }

  // periphery:ignore
  public enum SectionID: String, WebsiteSectionID {
    // Add the sections that you want your website to contain here:
    case articles
    case episodes
    case tutorials
    case newsletters
    case products
    
    var isIndexable : Bool {
      return self != .products
    }
  }

  // periphery:ignore
  public struct ItemMetadata: WebsiteItemMetadata {
    // Add any site-specific metadata that you want to use here.
    var featuredImage: String
    var date: Date
    var longArchiveURL: String?
    var featured: Bool?
    var issueNo: Int?
    var youtubeID: String?
    var audioDuration: TimeInterval?
    var videoDuration: TimeInterval?
    var podcastID: String?
    var subscriptionCTA: String?
    var platforms: String?
    var productURL: String?
    var appStoreURL: String?
    var pressKitURL: String?
    var technologies: String?
    var githubRepoName: String?
    var screenshots: [String]?
    var style: String?
    var isFeatured: Bool?
    var clipLogo: Bool?
  }

  public static var metadata: WebsiteMetadata {
    WebsiteMetadata(title: Self.SiteInfo.title)
  }

  public enum SiteInfo {
    public static let url = URL(staticString: "https://brightdigit.com")
    public static let name = "BrightDigit"
    public static let title = "BrightDigit | Expert Swift App Development"
    public static let description = "Need a specialist Swift developer for your business’s next app to grow sales and delight customers? We are your go-to for expert development in the Apple ecosystem. Learn more..."
    public static let imagePath: Path = "/android-chrome-512x512.png"
  }

  // Update these properties to configure your website:
  public let url = SiteInfo.url
  public let name = SiteInfo.name
  public let description = SiteInfo.description
  public var language: Language { .english }
  public var imagePath: Path? = SiteInfo.imagePath

  public static let mainJS = OutputPath.file("js/main.js")
  public static let npmPath = ProcessInfo.processInfo.environment["NPM_PATH"]

  static let now = Date()

  static let preMarkdownSteps: [PublishingStep<BrightDigitSite>] = [
    .optional(copyResourcesStep()),
    .group([
      .installPlugin(.transistor()),
      .installPlugin(.youtube()),
      .installPlugin(.splash(withClassPrefix: ""))
    ]),
    .addMarkdownFiles()
  ]

  static let postMarkdownSteps: [PublishingStep<BrightDigitSite>] = [
    .yamlStringFix,
    .installPlugin(.readingTime()),
    .sortItems(by: \.date, order: .descending),
    .generateHTML(withTheme: .company, indentation: .spaces(2)),
    .group([
      .generateRSSFeed(including: [.articles, .tutorials]),
      .generateRSSFeed(including: [.articles], config: .init(targetPath: "articles.rss")),
      .generateRSSFeed(including: [.tutorials], config: .init(targetPath: "tutorials.rss"))
    ]),

    .generateSiteMap(excluding: .init(["newsletters/", "products/"])),

    .npm(npmPath, at: "Styling") {
      ci()
      run(paths: [mainJS]) {
        "publish -- --output-filename"
        mainJS
      }
    }
  ]

  static let draftSteps = [
    preMarkdownSteps,
    postMarkdownSteps
  ].flatMap { $0 }

  static let productionSteps = [
    preMarkdownSteps,
    [
      .removeAllItems(matching: .init(matcher: { item in
        item.date > now
      }))
    ],
    postMarkdownSteps
  ].flatMap { $0 }
}

public extension BrightDigitSite {
  func publish(includeDrafts: Bool) async throws {
    let steps = includeDrafts ? Self.draftSteps : Self.productionSteps

    try await publish(using: steps)
  }
}
