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
      // rather than inside the per-item Source init, whose errors are ignored.
      let id = try id(item)
      #warning("Allow old episode errors to be ignored")
      return try? Source(item: item, id: id)
    }
  }
}
