//
//  FrontMatterTranslator.swift
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
import Foundation

extension BrightDigitPodcast {
  public struct FrontMatterTranslator: Contribute.FrontMatterTranslator {
    public typealias SourceType = Source
    public typealias FrontMatterType = FrontMatter

    public struct FrontMatter: Codable {
      internal let title: String
      internal let date: String
      internal let description: String
      internal let featuredImage: URL
      internal let youtubeID: String
      internal let audioDuration: Int
      internal let videoDuration: Int
      internal let podcastID: String

      public init(episode: SourceType) {
        title = episode.title
        date = YAML.dateFormatter.string(from: episode.date)
        description = episode.summary
        featuredImage = episode.media.imageURL
        youtubeID = episode.media.youtubeID
        audioDuration = Int(episode.media.podcastDuration)
        videoDuration = Int(episode.media.youtubeDuration)
        podcastID = episode.media.podcastID
      }
    }

    public init() {}

    public func frontMatter(from source: SourceType) -> FrontMatterType {
      FrontMatter(episode: source)
    }
  }
}
