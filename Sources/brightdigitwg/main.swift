import ArgumentParser
import Foundation
import Kanna
import Plot
import Publish
import ShellOut

extension Optional {
  func flatMap<OtherValueType>(and other: OtherValueType?) -> (Wrapped, OtherValueType)? {
    flatMap { value in
      other.map {
        (value, $0)
      }
    }
  }
}

public struct WordpressPost {
  public init(title: String, meta: [String: String], body: String, date: Date) {
    self.title = title
    self.meta = meta
    self.body = body
    self.date = date
  }

  public static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
    return formatter
  }()

  public let title: String
  public let meta: [String: String]
  public let body: String
  public let date: Date
}

public extension WordpressPost {
  init?(element: Kanna.XMLElement) {
    guard let title = element.at_css("title")?.content else {
      return nil
    }
    guard let pubDateString = element.at_css("pubDate")?.content else {
      return nil
    }
    guard let pubDate = Self.dateFormatter.date(from: pubDateString) else {
      return nil
    }
    guard let contentElement = element.at_xpath("content:encoded", namespaces: ["content": "http://purl.org/rss/1.0/modules/content/"]) else {
      return nil
    }
    guard let body = contentElement.text else {
      return nil
    }
    let metaElems = element.css("wp:postmeta", namespaces: ["wp": "http://wordpress.org/export/1.2/"])
    let meta = metaElems.compactMap { (element) -> (String, String)? in
      let key = element.at_css("wp:meta_key", namespaces: ["wp": "http://wordpress.org/export/1.2/"])?.content
      let value = element.at_css("wp:meta_value", namespaces: ["wp": "http://wordpress.org/export/1.2/"])?.content
      return key.flatMap(and: value)
    }.uniqueByKey()

    self.init(title: title, meta: meta, body: body, date: pubDate)
  }
}

extension Sequence {
  // @inlinable public init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value)
  func uniqueByKey<Key: Hashable, Value>() -> [Key: Value] where Element == (Key, Value) {
    return Dictionary(uniqueKeysWithValues: self)
  }

  func groupByKey<Key: Hashable, Value>() -> [Key: [Value]] where Element == (Key, Value) {
    return Dictionary(grouping: self, by: { $0.0 }).mapValues { $0.map(\.1) }
  }
}

// This type acts as the configuration for your website.
struct BrightDigit: Website {
  enum SectionID: String, WebsiteSectionID {
    // Add the sections that you want your website to contain here:
    case articles
    case episodes
    case videos
    case tutorials
  }

  struct ItemMetadata: WebsiteItemMetadata {
    // Add any site-specific metadata that you want to use here.
  }

  // Update these properties to configure your website:
  var url = URL(string: "https://brightdigit.com")!
  var name = "BrightDigit"
  var description = "A description of BrightdigitCom"
  var language: Language { .english }
  var imagePath: Path? { nil }
}

extension Plugin {
  @available(OSX 10.12, *)
  static var tailwindCss: Self {
    Plugin(name: "Tailwind") { context in
      let folder = try context.folder(at: "Content/styling")
      let cssFile = try context.createOutputFile(at: "css/styles.css")
      try shellOut(to: "npm run publish -- -o \(cssFile.url.absoluteString)", at: folder.path)
    }
  }
}

extension PublishingStep {
  static var tailwindCSS: Self {
    .step(named: "Create CSS From TailwindCSS") { context in
      let folder = try context.folder(at: "Styling")
      let cssFile = try context.createOutputFile(at: "css/styles.css")

      try shellOut(to: "npm install; npm run publish -- -o \(cssFile.path)", at: folder.path)
    }
  }
}

public struct BrightDigitSiteCommand: ParsableCommand {
  public init() {}

  public static var configuration = CommandConfiguration(
    abstract: "Command for maintaining the BrightDigit site.",
    subcommands: [PublishCommand.self, ImportCommand.self],
    defaultSubcommand: PublishCommand.self
  )
}

public extension BrightDigitSiteCommand {
  struct PublishCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(commandName: "publish")
    public init() {}

    public func run() throws {
      try BrightDigit().publish(using: [
        .optional(.copyResources()),
        .addMarkdownFiles(),
        .sortItems(by: \.date, order: .descending),

        .generateHTML(withTheme: .company, indentation: .spaces(2)),
        .generateSiteMap(),

        .tailwindCSS,
        .generateRSSFeed(including: [.articles, .tutorials])
      ])
    }
  }
}

public enum SiteImportType: String, ExpressibleByArgument {
  case wordpress
}

public extension BrightDigitSiteCommand {
  struct ImportCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(commandName: "import")
    @Option
    public var type: SiteImportType = .wordpress

    @Argument
    public var directory: String

    public init() {}

    public func run() throws {
      let directoryURL = URL(fileURLWithPath: directory)

      guard let enumerator = FileManager.default.enumerator(at: directoryURL, includingPropertiesForKeys: nil) else {
        return
      }

      let namesAndDocs: [(String, Kanna.XMLDocument)] = enumerator
        .compactMap { $0 as? URL }
        .compactMap { url in
          let ext = url.pathExtension.lowercased()
          let name = url.deletingPathExtension().lastPathComponent

          guard ext == "xml" else {
            return nil
          }

          let doc: Kanna.XMLDocument
          do {
            doc = try XML(url: url, encoding: .utf8)
          } catch {
            print(error)
            return nil
          }

          return (name, doc)
        }

      let dictionary = namesAndDocs.uniqueByKey()

      var allPosts = [String: [WordpressPost]]()

      for (name, doc) in dictionary {
        let elementsByType: [String: [Kanna.XMLElement]] = doc.css("item").compactMap { element in
          /*
           public var title: String
           public var description: String
           public var body: Body
           public var date: Date
           public var lastModified: Date
           public var imagePath: Path?
           public var audio: Audio?
           public var video: Video?
           tags
           */
          element.at_xpath("wp:post_type", namespaces: ["wp": "http://wordpress.org/export/1.2/"]).flatMap(\.content).map {
            ($0, element)
          }
        }.groupByKey()

        let posts = elementsByType["post"]?.compactMap(WordpressPost.init(element:))
        allPosts[name] = posts
      }
    }
  }
}

BrightDigitSiteCommand.main()
