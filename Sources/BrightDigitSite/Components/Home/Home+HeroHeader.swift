//
//  Home+HeroHeader.swift
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

extension Home {
  /// Homepage masthead: H1, two hero sections, and background video.
  internal struct HeroHeader: Component {
    internal var body: Component {
      Header {
        Main {
          Header {
            H1("Your Experts in Swift App Development")
          }
          Home.HeroSection(
            imageURL: nil,
            imageDescription: nil,
            text:
              // swiftlint:disable:next line_length
              "Join our newsletter to be the first to know when we have availability, plus advice on what's new with Apple apps and products.",
            linkTitle: "Subscribe Now",
            linkURL: "/newsletters"
          )
          Home.HeroSection(
            imageURL: "/media/swift-heroes.jpg",
            imageDescription: "Leo presenting at Swift Heroes",
            text:
              // swiftlint:disable:next line_length
              "Founded in 2012, BrightDigit aims to provide you with the very best in Swift-based development for the Apple ecosystem.",
            linkTitle: "Learn more about us",
            linkURL: "/about-us"
          )
        }
        Footer {
          Home.HeroBackgroundVideo()
        }
      }
    }
  }
}
