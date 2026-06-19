//
//  ServicesBuilder.swift
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
import Publish
import PublishType

internal struct ServicesBuilder: PageBuilder {
  internal let imagePath: Path = "/media/services/new2-12.png"

  internal let description: String =
    // swiftlint:disable:next line_length
    "Is your app making customers and driving sales? We help you create, rebuild and port apps to excite customers and boost your business."

  internal var bodyClasses: [String] { [] }

  // swiftlint:disable:next function_body_length
  internal func main(
    forLocation _: Page, withContext _: PublishingContext<BrightDigitSite>
  )
    -> [Node<HTML.BodyContext>]
  {
    [
      .components {
        Header {
          Element(name: "section") {
            Paragraph {
              Text("We work with ")
              Text("companies and agencies").italic()
              Text(" that want Swift-based apps that are:")
            }
            H1 {
              Text("Intuitive.").addLineBreak()
              Text("Effective.").addLineBreak()
              Text("Well-Designed.")
            }
          }
        }
        ServiceBox(
          id: "iPhone-service",
          bigImage: .init(
            url: "/media/services/new2-12.png", description: "Building a Brand New App"
          ),
          smallImage: Image(
            url: "/media/services/003-iphone.svg",
            description: "iPhone"
          ),
          title: "New App Development",
          text: Strings.Services.iOSDevelopment
        )

        ServiceBox(
          id: "swift-service",
          bigImage: .init(
            url: "/media/services/12-agustus-outline-02.png",
            description: "Upgrading an Existing App"
          ),
          smallImage: Image(
            url: "/media/services/001-swift.svg",
            description: "Swift Logo"
          ),
          title: "Upgrade Your Existing App",
          text: Strings.Services.consulting
        )

        ServiceBox(
          id: "apple-service",
          bigImage: .init(
            url: "/media/services/mar6-outline-07.png",
            description: "Porting an app over"
          ),
          smallImage: .init(
            url: "/media/services/002-smartwatch-app.svg",
            description: "Apple Watch"
          ),
          title: "Port Your App to Apple Platforms",
          text: Strings.Services.appleDevelopment
        )

        Element(name: "section") {
          Element(name: "main") {
            Header {
              H2 {
                Text("Check out some of the ")
                Text("work").bold()
                Text(" we've done...")
              }
            }
            Footer {
              Link("Our Work", url: "/products").class("button")
            }
          }
        }.class("products-cta")
      }
    ]
  }
}
