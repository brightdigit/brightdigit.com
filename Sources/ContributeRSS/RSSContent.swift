import Foundation
import Contribute
import SyndiKit

public enum RSSContent: ContentType {
  public typealias SourceType = Source
  public typealias MarkdownExtractorType = MarkdownExtractor
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

public extension RSSContent {  
  static func items(from rssURL: URL, id: KeyPath<RSSItem, String>) throws -> [Source] {
    let decoder = SynDecoder()
    let data = try Data(contentsOf: rssURL)
    let synfeed = try decoder.decode(data)
    guard let rssFeed = synfeed as? RSSFeed else {
      throw RSSError.invalidRSS(rssURL)
    }
    return try rssFeed.channel.items.map{
      try Source(item: $0, id: id)
    }
  }
}
