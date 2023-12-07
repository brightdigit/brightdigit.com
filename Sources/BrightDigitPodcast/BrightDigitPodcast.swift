import Foundation
import SyndiKit
import Contribute
import ContributeRSS

public struct BrightDigitPodcast: ContentType {
  public typealias SourceType = Source
  public typealias MarkdownExtractorType = MarkdownExtractor
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

public extension BrightDigitPodcast {
  static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    using htmlToMarkdown: @escaping (String) throws -> String,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try write(
      from: episodes,
      atContentPathURL: contentPathURL,
      fileNameWithoutExtension: fileNameWithoutExtensionFromSource(_:),
      using: htmlToMarkdown,
      options: options
    )
  }

  static func fileNameWithoutExtensionForEpisode(
    withNumber episodeNo: Int,
    title: String
  ) -> String {
    fileNameWithoutExtensionForEpisode(
      withNumber: episodeNo,
      slug: title.slugify()
    )
  }

  // MARK: - Helpers

  private static func fileNameWithoutExtensionFromSource(
    _ source: SourceType
  ) -> String {
    fileNameWithoutExtensionForEpisode(
      withNumber: source.episodeNo,
      slug: source.slug
    )
  }

  static func fileNameWithoutExtensionForEpisode(
    withNumber episodeNo: Int,
    slug: String
  ) -> String {
    let paddedEpisodeNo = episodeNo.description.padLeft(
      totalWidth: 3,
      byString: "0"
    )

    return "\(paddedEpisodeNo)-\(slug)"
  }
}
