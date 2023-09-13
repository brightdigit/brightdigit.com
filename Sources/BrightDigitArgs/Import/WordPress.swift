import ArgumentParser
import ContributeWordPress
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public extension BrightDigitSiteCommand.ImportCommand {
  struct WordPress: ParsableCommand {
    public static var configuration = CommandConfiguration(
      commandName: "wordpress",
      abstract: "Command for import WordPress export file into the BrightDigit site."
    )

    @Argument(help: "Directory which contains a single or multiple imports.", completion: CompletionKind.directory)
    public var wordpressExportsDirectory: String

    @Option(help: "Directory which contains images, pdf files, and other assets.", completion: CompletionKind.directory)
    public var importAssetsDirectory: String?

    @Option(help: "Path to Save Images Relative to Resources.")
    public var assetRelativePath = "media/wp-images"

    @Flag(help: "Overwrite Downloaded Assets.")
    public var overwriteAssets: Bool = false

    @Flag(help: "Skip Downloading Assets.")
    public var skipDownload: Bool = false

    public init() {}

    public static func markdownFrom(html: String) throws -> String {
      try BrightDigitSiteCommand.ImportCommand.markdownGenerator.markdown(fromHTML: html)
    }

    public func run() throws {
      let processor = try MarkdownProcessor(postFilters: [
        RegexKeyPostFilter(pattern: "post", keyPath: \.type),
        RegexKeyPostFilter(pattern: "^empowerapps-show", keyPath: \.name, not: true),
        RegexKeyPostFilter(pattern: "^$", keyPath: \.name, not: true),
        RegexKeyPostFilter(pattern: "publish", keyPath: \.status)
      ])

      let settings = Settings(
        rootPublishSiteURL: self.rootPublishPathURL,
        exportsDirectoryURL: self.exportsDirectoryURL,
        assetImportSetting: self.assetImportSetting,
        overwriteAssets: self.overwriteAssets,
        assetRelativePath: self.assetRelativePath
      )
      
      try processor.begin(withSettings: settings)
    }
  }
}
