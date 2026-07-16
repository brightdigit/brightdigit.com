//
//  Newsletter+SubscriptionForm.swift
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

extension Newsletter {
  /// The newsletter subscription form with the "be the first to know" message.
  internal struct SubscriptionForm: Component {
    internal let sourcePath: String

    internal var body: Component {
      Element(name: "form") {
        Div {
          Div {
            Node.input(
              .type(.text),
              .placeholder("leo@brightdigit.com"),
              .name("email")
            )
            Node.label("Email")
          }
        }
        Div {
          Div {
            Node.input(
              .type(.hidden),
              .name("metadata__source_page"),
              .value(sourcePath)
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
                Text(
                  "in the world of Swift and Apple software, and how they can help you."
                )
              }
            }
          }
        }.class("message")
      }
      .attribute(named: "action", value: Strings.Buttondown.subscribeURL)
      .attribute(named: "method", value: "post")
    }
  }
}
