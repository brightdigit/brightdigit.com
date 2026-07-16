//
//  NewsletterItem+Content.swift
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

extension NewsletterItem {
  internal var formComponent: Component {
    Element(name: "form") {
      Div {
        Div {
          Node<HTML.FormContext>.input(
            .type(.text),
            .placeholder("leo@brightdigit.com"),
            .name("email")
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
      Div {
        Div {
          H3 { Text("Be the first to know:") }
          Element(name: "ol") {
            ListItem {
              Text("When we publish")
              Element(name: "b") { Text(" new content ") }
              Text("on building better apps on our blog or podcast.")
            }
            ListItem {
              Text("Details about")
              Element(name: "b") { Text(" upcoming events and conferences ") }
              Text("Leo is speaking at.")
            }
            ListItem {
              Text("About the")
              Element(name: "b") { Text(" latest developments ") }
              Text("in the world of Swift and Apple software, and how they can help you.")
            }
          }
        }
      }.class("message")
    }
    .attribute(named: "action", value: Strings.Buttondown.subscribeURL)
    .attribute(named: "method", value: "post")
  }

  private var itemFooter: Component {
    Footer {
      Text("published on")
      Span {
        Text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
      }.class("published-date")
    }
  }

  internal var featuredItemContent: Node<HTML.BodyContext> {
    Header {
      Element(name: "section") {
        H1 {
          Text("Don't Let Your App")
          Element(name: "em") { Text("Fall Behind") }
        }
        Paragraph { Text("\(Strings.Newsletter.featuredParagraph)") }
      }
      Element(name: "section") {
        formComponent
        Element(name: "section") {
          Header {
            H3 { Text("Featured issue") }
            Image(featuredImageURL)
            Link(url: archiveURL) {
              H2 { Text(title) }
            }
          }
          Main {
            Text(description)
          }
          itemFooter
        }.class("featured")
      }.class("hero")
    }.convertToNode()
  }

  internal var sectionItemContent: [Node<HTML.BodyContext>] {
    [
      .id("issue-\(issueNo)"),
      Header {
        Image(featuredImageURL)
        Link(url: archiveURL) {
          H2 { Text(title) }
        }
      }.convertToNode(),
      Main {
        Text(description)
      }.convertToNode(),
      itemFooter.convertToNode(),
    ]
  }
}
