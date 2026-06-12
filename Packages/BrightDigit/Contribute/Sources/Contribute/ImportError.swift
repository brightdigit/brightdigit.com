//
//  ImportError.swift
//  Contribute
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

/// Errors that can occur while importing content from external sources
/// such as RSS feeds, YouTube, and Mailchimp.
@available(*, deprecated)
public enum ImportError: Error {
  case directory(URL)
  case imageDownloads([URL: Error])
  case invalidPodcastEpisodeFromRSSItem(Any)
  case invalidRSS(URL)
  case apiError(Error)
  case missingResponseFromPlaylistID(String, ResponseComponent)
  case unknownError(Error)
  case missingFieldForVideo(Any, VideoField)
  case missingVideoForEpisode(Any)
  case missingFieldFromPodcastEpisode(Any, EpisodeField)
  case duplicateTitle(String, forVideos: [Any])
  case invalidMailchimp
  case newsletterMissingField(NewsletterField)
  case missingHTMLForCampaignID(String)

  /// The component of an API response that was missing or invalid.
  public enum ResponseComponent {
    case anyResponse
    case success
    case items
  }

  /// A field that was missing from a video.
  public enum VideoField {
    case snippetTitle
    case id
    case duration
    case description
  }

  /// A field that was missing from a podcast episode.
  public enum EpisodeField {
    case duration
    case title
    case episode
    case summary
    case imageHref
  }

  /// A field that was missing from a newsletter campaign.
  public enum NewsletterField {
    case id
    case longArchiveURL
    case title
    case subjectLine
    case sendTime
  }
}
