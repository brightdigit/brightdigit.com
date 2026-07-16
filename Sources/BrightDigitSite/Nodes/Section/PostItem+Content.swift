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
    Header {
      Element(name: "section") {
        Element(name: "section") {
          Header {
            Image(featuredImageURL)
          }
          Main {
            Header {
              Link(url: source.path.absoluteString) {
                H2 { Text(title) }
              }
            }
            Main {
              Text(description)
            }
            Footer {
              Text(" published on ")
              Span {
                Text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
              }.class("published-date")
            }
          }
        }.class("featured")
      }.class("hero")
    }.convertToNode()
  }

  internal var sectionItemContent: [Node<HTML.BodyContext>] {
    [
      .id("post-\(slug)"),
      Header {
        Image(featuredImageURL)
        Link(url: source.path.absoluteString) {
          H2 { Text(title) }
        }
      }.convertToNode(),
      Main {
        Text(description)
      }.convertToNode(),
      Footer {
        // Original markup is `<a>date</a>` with no href attribute.
        Node<HTML.BodyContext>.a(
          .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
        )
      }.convertToNode(),
    ]
  }

  internal var pageHeader: Node<HTML.BodyContext> {
    Header {
      Header {
        Image(featuredImageURL)
        H1 { Text(title) }
      }
      Footer {
        Element(name: "ol") {
          for share in SocialShares.shares {
            shareListItem(for: share)
          }
        }
        Div {
          Text("\(source.readingTime.minutes) mins")
        }.class("readtime")
      }
    }.convertToNode()
  }

  internal var pageFooter: Node<HTML.BodyContext> {
    Footer {
      Element(name: "ol") {
        for share in SocialShares.shares {
          shareListItem(for: share)
        }
      }
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
            Node<HTML.BodyContext>.markdown(
              // swiftlint:disable:next line_length
              "A couple of times a month, I publish a [newsletter](/newsletters), with news, updates, and other content related to Apple and iOS. I try to help people better understand how to succeed with iOS apps, and keep you informed about what’s coming up on the horizon for the industry."
            )
          }
        }
        subscriptionForm
      }
    }.convertToNode()
  }

  private var subscriptionForm: Component {
    Element(name: "form") {
      Div {
        Div {
          Node<HTML.FormContext>.input(
            .type(.email), .name("email"), .placeholder("leo@brightdigit.com")
          )
          Node<HTML.FormContext>.label("Email")
        }
      }
      Div {
        Div {
          Node<HTML.FormContext>.input(
            .type(.hidden),
            .name("metadata__source_page"),
            .value(source.path.string)
          )
          Button {
            Text("Sign me up!")
          }.attribute(named: "type", value: "submit")
            .class(Strings.Plausible.newsletterSignupEventClass)
        }
      }
    }
    .attribute(named: "action", value: Strings.Buttondown.subscribeURL)
    .attribute(named: "method", value: "post")
  }

  internal func shareListItem(for share: SocialShare) -> Component {
    ListItem {
      Link(url: share.shareURL(for: self)) {
        Span {
          Text(share.actionText)
        }.class("action")
        Span {
          Text(share.nameText)
        }.class("name")
        Icon(className: "flaticon-\(share.flaticonName)")
      }.linkTarget(.blank)
    }
  }
}
