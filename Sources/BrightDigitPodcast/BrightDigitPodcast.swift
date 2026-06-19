//
//  BrightDigitPodcast.swift
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

import Contribute
import ContributeRSS
import Foundation
import SyndiKit

public struct BrightDigitPodcast: ContentType {
  public typealias SourceType = Source
  public typealias MarkdownExtractorType = MarkdownExtractor
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

extension BrightDigitPodcast {
  public static func write(
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

  public static func fileNameWithoutExtensionForEpisode(
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

  public static func fileNameWithoutExtensionForEpisode(
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
