//
//  ProductSection.swift
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

/// Product portfolio card body (header links, main content, technologies footer).
internal struct ProductSection: Component {
  internal let product: ProductItem

  internal var body: Component {
    ComponentGroup {
      Header {
        Link(url: product.productURL) {
          Image(url: product.logo, description: "\(product.title) logo")
            .class(product.clipLogo ? "" : "no-clip")
          H2 {
            Text(product.title)
          }
        }.linkTarget(.blank)
        List {
          ListItem {
            Link("Product Page", url: product.productURL)
            if let appStoreURL = product.appStoreURL {
              ListItem {
                Link(url: appStoreURL) {
                  Icon(className: "flaticon-app")
                  Text("AppStore")
                }.linkTarget(.blank)
              }
            }
            if let githubURL = product.githubURL {
              ListItem {
                Link(url: githubURL) {
                  Icon(className: "flaticon-github")
                  Text("GitHub")
                }.linkTarget(.blank)
              }
            }
            if let pressKitURL = product.pressKitURL {
              ListItem {
                Link(url: pressKitURL) {
                  Icon(className: "flaticon-press-release")
                  Text("Press Kit")
                }.linkTarget(.blank)
              }
            }
          }
        }.class("links")

        List(product.platforms) { platform in
          ListItem(platform)
        }.class("platforms")
      }
      Element(name: "main") {
        product.source.body.node
        List(product.screenshots) { screenshotURL in
          ListItem {
            Image(screenshotURL)
          }
        }.class("screenshots \(product.style.rawValue)")
        // swiftlint:disable:next line_length
        //          List(product.pressCoverage, content: ListItem.init(forPressCoverage:)).class("press-coverage")
      }
      Footer {
        SectionElement {
          H4(Text("Technologies"))
          List(product.technologies) { tech in
            ListItem(Text(tech))
          }
        }
      }
    }
  }
}
