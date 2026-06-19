//
//  EmailSocialShare.swift
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

internal struct EmailSocialShare: SocialQueryItemsShare {
  internal static let baseURLComponents = URLComponents(staticString: "mailto:")

  internal let flaticonName: String = "newsletter"

  internal let actionText: String = "Share With"
  internal let nameText: String = "Email"

  internal func queryItems<PostableType>(for item: PostItem<PostableType>)
    -> [URLQueryItem]
  where PostableType: Postable {
    var queryItems: [URLQueryItem] = []
    queryItems.append(URLQueryItem(name: "subject", value: item.title))
    queryItems.append(
      URLQueryItem(name: "body", value: "\(item.description)\n\n\(item.absoluteURL)")
    )
    return queryItems
  }
}
