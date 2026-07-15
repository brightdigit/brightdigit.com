//
//  BrightDigitSite.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import NPMPublishPlugin
import Plot
import Publish
import PublishType
import ReadingTimePublishPlugin
import TransistorPublishPlugin
import YoutubePublishPlugin

internal func copyDirectory(from sourcePath: String, to destinationPath: String) throws {
  let fileManager = FileManager.default

  // Check if source directory exists
  var isDirectory: ObjCBool = false
  guard fileManager.fileExists(atPath: sourcePath, isDirectory: &isDirectory),
    isDirectory.boolValue
  else {
    throw NSError(
      domain: "DirectoryCopyError", code: 1,
      userInfo: [
        NSLocalizedDescriptionKey: "Source path is not a directory or doesn't exist."
      ]
    )
  }

  // Create destination directory if it doesn't exist
  if !fileManager.fileExists(atPath: destinationPath) {
    try fileManager.createDirectory(
      atPath: destinationPath, withIntermediateDirectories: true
    )
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

internal func copyResourcesStep() -> PublishingStep<BrightDigitSite> {
  .step(named: "Copy Resources") { context in
    let sourcePath = try context.folder(at: "Resources").path
    let destinationPath = try context.outputFolder(at: "").path
    try copyDirectory(from: sourcePath, to: destinationPath)
  }
}

// This type acts as the configuration for your website.
public struct BrightDigitSite: Website, MetadataAttached {
  // periphery:ignore
  public enum SectionID: String, WebsiteSectionID {
    // Add the sections that you want your website to contain here:
    case articles
    case episodes
    case tutorials
    case newsletters
    case products

    internal var isIndexable: Bool {
      self != .products
    }
  }

  // periphery:ignore
  public struct ItemMetadata: WebsiteItemMetadata {
    // Add any site-specific metadata that you want to use here.
    internal var featuredImage: String
    internal var date: Date
    internal var longArchiveURL: String?
    internal var featured: Bool?
    internal var issueNo: Int?
    internal var youtubeID: String?
    internal var audioDuration: TimeInterval?
    internal var videoDuration: TimeInterval?
    internal var podcastID: String?
    internal var subscriptionCTA: String?
    internal var platforms: String?
    internal var productURL: String?
    internal var appStoreURL: String?
    internal var pressKitURL: String?
    internal var technologies: String?
    internal var githubRepoName: String?
    internal var screenshots: [String]?
    internal var style: String?
    internal var isFeatured: Bool?
    internal var clipLogo: Bool?
  }

  public enum SiteInfo {
    public static let url = URL(staticString: "https://brightdigit.com")
    public static let name = "BrightDigit"
    public static let title = "BrightDigit | Expert Swift App Development"
    public static let description =
      // swiftlint:disable:next line_length
      "Need a specialist Swift developer for your business’s next app to grow sales and delight customers? We are your go-to for expert development in the Apple ecosystem. Learn more..."
    public static let imagePath: Path = "/android-chrome-512x512.png"
  }

  public static var metadata: WebsiteMetadata {
    WebsiteMetadata(title: Self.SiteInfo.title)
  }

  public static let mainJS = OutputPath.file("js/main.js")
  public static let npmPath = ProcessInfo.processInfo.environment["NPM_PATH"]

  internal static let now = Date()

  internal static let preMarkdownSteps: [PublishingStep<BrightDigitSite>] = [
    .optional(copyResourcesStep()),
    .group([
      .installPlugin(.transistor()),
      .installPlugin(.youtube()),
      // Syntax highlighting is now handled client-side (highlight.js in the
      // Styling bundle) rather than by the removed Splash plugin; Ink emits
      // `<pre><code class="language-xxx">` which highlight.js targets directly.
    ]),
    .addMarkdownFiles(),
  ]

  internal static let postMarkdownSteps: [PublishingStep<BrightDigitSite>] = [
    .yamlStringFix,
    .installPlugin(.readingTime()),
    .sortItems(by: \.date, order: .descending),
    .generateHTML(withTheme: .company, indentation: .spaces(2)),
    .group([
      .generateRSSFeed(including: [.articles, .tutorials]),
      .generateRSSFeed(including: [.articles], config: .init(targetPath: "articles.rss")),
      .generateRSSFeed(
        including: [.tutorials], config: .init(targetPath: "tutorials.rss")
      ),
    ]),

    .generateSiteMap(excluding: .init(["newsletters/", "products/"])),

    .npm(npmPath, at: "Styling") {
      ci()
      run(paths: [mainJS]) {
        "publish -- --output-filename"
        mainJS
      }
    },
  ]

  internal static let draftSteps = [
    preMarkdownSteps,
    postMarkdownSteps,
  ].flatMap { $0 }

  internal static let productionSteps = [
    preMarkdownSteps,
    [
      .removeAllItems(
        matching: .init(matcher: { item in
          item.date > now
        })
      )
    ],
    postMarkdownSteps,
  ].flatMap { $0 }

  // Update these properties to configure your website:
  public let url = SiteInfo.url
  public let name = SiteInfo.name
  public let description = SiteInfo.description
  public var language: Language { .english }
  public var imagePath: Path? = SiteInfo.imagePath

  public init(imagePath: Path? = SiteInfo.imagePath) {
    self.imagePath = imagePath
  }
}

extension BrightDigitSite {
  public func publish(includeDrafts: Bool) async throws {
    let steps = includeDrafts ? Self.draftSteps : Self.productionSteps

    try await publish(using: steps)
  }
}
