import ArgumentParser
import Foundation
import Kanna
import Plot
import Publish
import ShellOut

extension Sequence {
  // @inlinable public init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value)
  func uniqueKeys<Key: Hashable, Value>() -> [Key: Value] where Element == (Key, Value) {
    return Dictionary(uniqueKeysWithValues: self)
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

      let dictionary = namesAndDocs.uniqueKeys()

      for (name, doc) in dictionary {
        let postTypes = doc.css("item").compactMap {
          $0.at_xpath("wp:post_type", namespaces: ["wp": "http://wordpress.org/export/1.2/"])?.content
        }
        print(Set(postTypes))
      }
    }
  }
}

BrightDigitSiteCommand.main()
