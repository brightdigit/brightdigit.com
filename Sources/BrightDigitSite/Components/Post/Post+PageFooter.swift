//
//  Post+PageFooter.swift
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

import Plot

extension Post {
  /// The post page footer: share list plus the newsletter subscription CTA.
  internal struct PageFooter: Component {
    internal let shareItems: [Post.ShareListItem]
    internal let subscriptionCTA: String?
    internal let sourcePath: String

    internal var body: Component {
      Footer {
        Post.ShareList(items: shareItems)
        Main {
          Main {
            if let subscriptionCTA {
              H2 { Text(subscriptionCTA) }
            }
            H3 {
              Text(
                // swiftlint:disable:next line_length
                "The BrightDigit newsletter gives you regular helpful tips and advice right to your inbox!"
              )
            }
            Paragraph {
              Node.markdown(
                // swiftlint:disable:next line_length
                "A couple of times a month, I publish a [newsletter](/newsletters), with news, updates, and other content related to Apple and iOS. I try to help people better understand how to succeed with iOS apps, and keep you informed about what’s coming up on the horizon for the industry."
              )
            }
          }
          Post.SubscriptionForm(sourcePath: sourcePath)
        }
      }
    }
  }
}
