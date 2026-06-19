//
//  BrightDigitPodcast.Source.swift
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

extension BrightDigitPodcast.Source {
  public init(
    podcastID: String,
    audio: AudioPodcastItem,
    video: VideoYouTubeItem
  ) throws {
    let media: BrightDigitPodcastMedia = .init(
      youtubeID: video.youtubeID,
      videoDuration: video.duration,
      podcastID: audio.podcastID,
      audioDuration: audio.duration,
      audioURL: audio.audioURL,
      imageURL: audio.imageURL
    )
    self.init(
      episodeNo: audio.episodeNo,
      slug: audio.slug,
      title: audio.title,
      date: audio.date,
      summary: audio.summary,
      content: audio.content,
      media: media
    )
  }

  /// Builds a podcast source for every RSS item, pairing it with its video.
  ///
  /// A missing video is fatal: if `fetchVideo` returns `nil` for any item this
  /// throws ``MediaError/missingVideoForEpisode(episodeNo:title:)`` rather than
  /// silently dropping the episode, so the import never publishes a site that is
  /// missing an episode without anyone noticing.
  public static func episodesBasedOn(
    rssItems: [AudioPodcastItem],
    fetchVideo: @escaping (AudioPodcastItem) -> VideoYouTubeItem?
  ) throws -> [BrightDigitPodcastSource] {
    try rssItems.map { rssItem in
      guard let video = fetchVideo(rssItem) else {
        throw MediaError.missingVideoForEpisode(
          episodeNo: rssItem.episodeNo,
          title: rssItem.title
        )
      }
      return try .init(
        podcastID: rssItem.podcastID,
        audio: rssItem,
        video: video
      )
    }
  }
}
