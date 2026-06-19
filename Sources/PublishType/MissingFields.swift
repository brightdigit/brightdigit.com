//
//  MissingFields.swift
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

public enum MissingFields {
  public enum NewsletterField: String, MissingField {
    case issueNo
    case archiveURL

    public static let typeName: String = "Newsletter"
    public var fieldName: String {
      rawValue
    }
  }

  public enum PodcastField: String, MissingField {
    case episodeNo
    case audioDuration
    case transistorID
    public static let typeName: String = "PodcastEpisode"
    public var fieldName: String {
      rawValue
    }
  }

  public enum ProductField: String, MissingField {
    case platforms
    case productURL
    case technologies
    case screenshots
    public static let typeName: String = "Product"
    public var fieldName: String {
      rawValue
    }
  }
}
