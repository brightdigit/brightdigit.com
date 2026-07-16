//
//  IndexServicesSection.swift
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

/// Homepage “Experts in Swift” services teaser list.
internal struct IndexServicesSection: Component {
  internal var body: Component {
    Element(name: "section") {
      Header {
        H2("Experts in Swift")
        Image(url: "/media/services/001-swift.svg", description: "Swift Logo")
      }
      Element(name: "ol") {
        IndexServiceListItem(
          title: "Is your app still at the idea stage?",
          imageSrc: "/media/services/003-iphone.svg",
          imageAlt: "iPhone",
          paragraph:
            // swiftlint:disable:next line_length
            "We provide consulting services to make sure you can deliver the best user experience from the ground up.",
          linkID: "iPhone-service"
        )
        IndexServiceListItem(
          title: "Have you started development and need specialist support?",
          imageSrc: "/media/services/002-smartwatch-app.svg",
          imageAlt: "Apple Watch",
          paragraph:
            // swiftlint:disable:next line_length
            "We specialize in Swift development for apps, large and small. If you've run into development trouble, we can help get back on track",
          linkID: "swift-service"
        )
        IndexServiceListItem(
          title:
            // swiftlint:disable:next line_length
            "Do you have an existing app but want to go bigger, better or port to an Apple platform?",
          imageSrc: "/media/services/004-cloud.svg",
          imageAlt: "The Cloud",
          paragraph:
            // swiftlint:disable:next line_length
            "We believe that platform-native development is almost always best. If you have an app for Android we can help you make a twin app that works seamlessly on iOS.",
          linkID: "apple-service"
        )
      }
    }.class("services")
  }
}
