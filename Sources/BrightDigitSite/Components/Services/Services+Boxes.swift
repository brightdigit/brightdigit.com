//
//  Services+Boxes.swift
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

extension Services {
  /// The three service offering boxes on the services page.
  internal struct Boxes: Component {
    internal var body: Component {
      ComponentGroup {
        Services.Box(
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
        Services.Box(
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
        Services.Box(
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
      }
    }
  }
}
