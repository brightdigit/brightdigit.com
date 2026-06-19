import Contribute
import Foundation
import SyndiKit

public enum RSSContent: ContentType {
  public typealias SourceType = Source
  public typealias MarkdownExtractorType = MarkdownExtractor
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

extension RSSContent {
  public static func items(from rssURL: URL, id: (RSSItem) throws -> String) throws
    -> [Source]
  {
    let decoder = SynDecoder()
    let data = try Data(contentsOf: rssURL)
    let synfeed = try decoder.decode(data)
    guard let rssFeed = synfeed as? RSSFeed else {
      throw RSSError.invalidRSS(rssURL)
    }
    return try rssFeed.channel.items.compactMap { item in
      // A missing id makes the whole feed invalid for us, so it throws here
      // rather than inside the per-item Source init.
      let id = try id(item)
      // Per-item parse failures are skipped (old/malformed episodes lack fields
      // we require) but logged, so a dropped episode is never silent.
      do {
        return try Source(item: item, id: id)
      } catch {
        FileHandle.standardError.write(
          Data("import: skipping RSS item id=\(id): \(error)\n".utf8)
        )
        return nil
      }
    }
  }
}
