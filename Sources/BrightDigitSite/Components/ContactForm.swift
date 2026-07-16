//
//  ContactForm.swift
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

/// Netlify contact form (`name="contact"`).
internal struct ContactForm: Component {
  internal var body: Component {
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
}
