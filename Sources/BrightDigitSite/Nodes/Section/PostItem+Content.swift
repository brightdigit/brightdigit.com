//
//  PostItem+Content.swift
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
import Plot
import Publish
import PublishType

extension PostItem {
  internal var featuredItemContent: Node<HTML.BodyContext> {
    .header(
      .section(
        .class("hero"),
        .section(
          .class("featured"),
          .header(
            .img(.src(featuredImageURL))
          ),
          .main(
            .header(
              .a(
                .href(source.path),
                .h2(.text(title))
              )
            ),
            .main(
              .text(description)
            ),
            .footer(
              " published on ",
              .span(
                .class("published-date"),
                .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
              )
            )
          )
        )
      )
    )
  }

  internal var sectionItemContent: [Node<HTML.BodyContext>] {
    [
      .id("post-\(slug)"),
      .header(
        .img(.src(featuredImageURL)),
        .a(
          .href(source.path),
          .h2(.text(title))
        )
      ),
      .main(
        .text(description)
      ),
      .footer(
        .a(
          .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
        )
      ),
    ]
  }

  internal var pageHeader: Node<HTML.BodyContext> {
    .header(
      .header(
        .img(.src(featuredImageURL)),
        .h1(.text(title))
      ),
      .footer(
        .ol(
          .forEach(SocialShares.shares, shareListItem(for:))
        ),
        .div(
          .class("readtime"),
          .text("\(source.readingTime.minutes) mins")
        )
      )
    )
  }

  internal var pageFooter: Node<HTML.BodyContext> {
    .footer(
      .ol(
        .forEach(SocialShares.shares, shareListItem(for:))
      ),
      .main(
        .main(
          .unwrap(subscriptionCTA) {
            .h2(.text($0))
          },
          .h3(
            // swiftlint:disable:next line_length
            "The BrightDigit newsletter gives you regular helpful tips and advice right to your inbox!"
          ),
          .p(
            .markdown(
              // swiftlint:disable:next line_length
              "A couple of times a month, I publish a [newsletter](/newsletters), with news, updates, and other content related to Apple and iOS. I try to help people better understand how to succeed with iOS apps, and keep you informed about what’s coming up on the horizon for the industry."
            )
          )
        ),

        .form(
          .action(Strings.Buttondown.subscribeURL),
          .method(.post),
          .div(
            .div(
              .input(.type(.email), .name("email"), .placeholder("leo@brightdigit.com")),
              .label("Email")
            )
          ),
          .div(
            .div(
              .input(
                .type(.hidden),
                .name("metadata__source_page"),
                .value(source.path.string)
              ),
              .button(
                .type(.submit),
                .class(Strings.Plausible.newsletterSignupEventClass),
                .text("Sign me up!")
              )
            )
          )
        )
      )
    )
  }

  internal func shareListItem(for share: SocialShare) -> Node<HTML.ListContext> {
    .li(
      .a(
        .href(share.shareURL(for: self)),
        .target(.blank),
        .span(
          .class("action"),
          .text(share.actionText)
        ),
        .span(
          .class("name"),
          .text(share.nameText)
        ),
        .i(.class("flaticon-\(share.flaticonName)"))
      )
    )
  }
}
