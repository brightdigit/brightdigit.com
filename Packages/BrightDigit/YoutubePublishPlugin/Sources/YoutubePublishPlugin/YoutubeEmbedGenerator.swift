//
//  YoutubeEmbedGenerator.swift
//  YoutubePublishPlugin
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

internal struct YoutubeEmbedGenerator {
  internal struct Error: LocalizedError {
    internal static let invalidURL = Error(localizedDescription: "Failed to construct an URL")
    internal static let timeout = Error(
      localizedDescription: "The request to Twitter's embed API timed out"
    )

    internal var localizedDescription: String
  }

  internal let youtubeURL: URL

  private var config: YoutubeEmbedConfiguration

  internal init(url: URL, configuration: YoutubeEmbedConfiguration) {
    self.youtubeURL = url
    self.config = configuration
  }

  internal func generate() -> Result<EmbeddedYoutube, Error> {
    guard let components = URLComponents(url: youtubeURL, resolvingAgainstBaseURL: false) else {
      return .failure(.invalidURL)
    }

    // condition: www.youtube.com
    if let videoID = components.queryItems?.compactMap({ $0 }).first(where: { $0.name == "v" })?.value {
      return .success(
        EmbeddedYoutube(
          width: config.width,
          height: config.height,
          html: html(from: videoID)
        )
      )
    }

    // condition: youtu.be/0HHAo1mLgxY
    // https://youtu.be/0HHAo1mLgxY
    guard let host = components.host, host == "youtu.be" else {
      return .failure(.invalidURL)
    }

    return .success(
      EmbeddedYoutube(width: config.width, height: config.height, html: html(from: components.path))
    )
  }

  private func html(from videoID: String) -> String {
    "<div class=\"youtube\"><iframe width=\"560\" height=\"315\" "
      + "src=\"https://www.youtube.com/embed/\(videoID)\" frameborder=\"0\" "
      + "allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; "
      + "gyroscope; picture-in-picture\" allowfullscreen></iframe></div>"
  }
}
