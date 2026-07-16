//
//  ContactBuilder.swift
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

internal struct ContactBuilder: PageBuilder {
  internal let description: String =
    "Ready to talk about your app and if we can help you build it? Contact us now!"

  internal var imagePath: Path = "/media/contact-us.png"

  internal var bodyClasses: [String] { [] }

  internal func main(
    forLocation _: Page, withContext _: PublishingContext<BrightDigitSite>
  )
    -> [Node<HTML.BodyContext>]
  {
    [
      Header {
        H1("Contact Us")
      }.convertToNode(),
      Self.makeContactUsFormWithPicture.convertToNode(),
      Self.makeSocialMediaSection.convertToNode(),
    ]
  }
}

extension ContactBuilder {
  // MARK: - makeContactUsFormWithPicture

  fileprivate static var makeContactUsFormWithPicture: Component {
    Element(name: "section") {
      Main {
        Header {
          Image(url: "/media/contact-us.svg", description: "Contact Us")
        }
        Main {
          Div {
            Paragraph {
              Text(
                // swiftlint:disable:next line_length
                "Want to chat about how we can help you and your company? Let us know how we help."
              )
            }
            contactForm
          }
        }
      }
    }.id("contact-us-form")
  }

  private static var contactForm: Component {
    Element(name: "form") {
      Div {
        Div {
          Node<HTML.FormContext>.input(
            .type(.text), .name("first-name"), .placeholder("Leo")
          )
          Node<HTML.FormContext>.label("First Name")
        }
        Div {
          Node<HTML.FormContext>.input(
            .type(.text), .name("last-name"), .placeholder("Dion")
          )
          Node<HTML.FormContext>.label("Last Name")
        }
      }
      Div {
        Div {
          Node<HTML.FormContext>.input(
            .type(.text), .name("email"), .placeholder("leo@brightdigit.com")
          )
          Node<HTML.FormContext>.label("Email")
        }
      }
      Div {
        Div {
          Node<HTML.FormContext>.textarea(
            .placeholder("You Message Here"), .name("message")
          )
        }
      }
      Div {
        Div {
          Node<HTML.FormContext>.button("Send", .type(.submit))
        }
      }
    }
    .attribute(named: "name", value: "contact")
    .attribute(named: "method", value: "post")
    .attribute(named: "data-netlify", value: "true")
  }

  // MARK: - makeSocialMediaSection

  fileprivate static var makeSocialMediaSection: Component {
    Element(name: "section") {
      Main {
        Header {
          Image(url: "/media/social-media.svg", description: "We are on Social Media")
        }
        Main {
          Paragraph { Text("There are other ways to get a hold of us too.") }
          Element(name: "ol") {
            makeIconWithText("Twitter @brightdigit", href: "/", flatIcon: "twitter")
            makeIconWithText("GitHub @brightdigit", href: "/", flatIcon: "github")
            makeIconWithText("EmpowerApps.Show Podcast", href: "/", flatIcon: "podcast")
            makeIconWithText("Youtube videos", href: "/", flatIcon: "youtube")
            makeIconWithText("Our Newsletter", href: "/", flatIcon: "newletter")
            makeIconWithText("Our Feed", href: "/", flatIcon: "rss")
          }.class("social")
        }
      }
    }.id("social-media")
  }

  // MARK: - makeIconWithText

  fileprivate static func makeIconWithText(
    _ text: String, href: String, flatIcon: String
  ) -> Component {
    ListItem {
      // Raw <a>: href, then <i> icon, then text — matches original node order.
      Node<HTML.BodyContext>.a(
        .href(href),
        .i(.class("flaticon-\(flatIcon)")),
        .text(text)
      )
    }
  }
}
