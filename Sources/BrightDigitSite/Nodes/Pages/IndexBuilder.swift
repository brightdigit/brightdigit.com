//
//  IndexBuilder.swift
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

// MARK: - BodyContext

internal struct IndexBuilder: ContentBuilder {
  internal typealias LocationType = Index

  internal let description: String = BrightDigitSite.SiteInfo.description
  internal var imagePath: Path = BrightDigitSite.SiteInfo.imagePath

  internal var bodyClasses: [String] { [] }

  internal func main(
    forLocation _: Index, withContext context: PublishingContext<BrightDigitSite>
  )
    -> [Node<HTML.BodyContext>]
  {
    [
      Self.mainHeader.convertToNode(),
      Self.sectionForServices.convertToNode(),
      Self.sectionForTestimonials.convertToNode(),
      Self.sectionForLatestArticles(basedOn: context).convertToNode(),
      Self.sectionForNewsletterCTA.convertToNode(),
    ]
  }
}

extension IndexBuilder {
  // MARK: - Main Header

  fileprivate static var mainHeader: Component {
    Header {
      Main {
        Header {
          H1("Your Experts in Swift App Development")
        }
        sectionForHero1
        sectionForHero2
      }
      Footer {
        // Bespoke `<video>` with autoplay/muted/loop + `<source>` typed nodes.
        Node<HTML.BodyContext>.video(
          .attribute(named: "autoplay"),
          .attribute(named: "muted"),
          .attribute(named: "loop"),
          .source(
            .src("/media/iPhone.mov"),
            .attribute(named: "type", value: "video/quicktime")
          ),
          .source(
            .src("/media/iPhone.webm"),
            .type(.webM)
          )
        )
      }
    }
  }

  // MARK: - sectionForHero

  fileprivate static var sectionForHero1: Component {
    Element(name: "section") {
      Main {
        Element(name: "section") {
          Main {
            Text(
              // swiftlint:disable:next line_length
              "Join our newsletter to be the first to know when we have availability, plus advice on what's new with Apple apps and products."
            )
          }
        }.class("text")
        Footer {
          Link("Subscribe Now", url: "/newsletters")
        }
      }
    }.class("hero")
  }

  fileprivate static var sectionForHero2: Component {
    Element(name: "section") {
      Header {
        Image(
          url: "/media/swift-heroes.jpg", description: "Leo presenting at Swift Heroes"
        )
      }
      Main {
        Element(name: "section") {
          Main {
            Text(
              // swiftlint:disable:next line_length
              "Founded in 2012, BrightDigit aims to provide you with the very best in Swift-based development for the Apple ecosystem."
            )
          }
        }.class("text")
        Footer {
          Link("Learn more about us", url: "/about-us")
        }
      }
    }.class("hero")
  }

  // MARK: - sectionForServices

  fileprivate static var sectionForServices: Component {
    Element(name: "section") {
      Header {
        H2("Experts in Swift")
        Image(url: "/media/services/001-swift.svg", description: "Swift Logo")
      }
      Element(name: "ol") {
        makeService(
          title: "Is your app still at the idea stage?",
          imageSrc: "/media/services/003-iphone.svg",
          imageAlt: "iPhone",
          paragraph:
            // swiftlint:disable:next line_length
            "We provide consulting services to make sure you can deliver the best user experience from the ground up.",
          linkID: "iPhone-service"
        )
        makeService(
          title: "Have you started development and need specialist support?",
          imageSrc: "/media/services/002-smartwatch-app.svg",
          imageAlt: "Apple Watch",
          paragraph:
            // swiftlint:disable:next line_length
            "We specialize in Swift development for apps, large and small. If you've run into development trouble, we can help get back on track",
          linkID: "swift-service"
        )
        makeService(
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

  // MARK: - sectionForTestimonials

  fileprivate static var sectionForTestimonials: Component {
    Element(name: "section") {
      Header {
        H2("Testimonials")
      }
      Element(name: "ol") {
        for testimonial in Testimonial.all.sorted() {
          Testimonial.listItem(testimonial)
        }
      }
    }.id("testimonials")
  }

  // MARK: - sectionForNewsletterCTA

  fileprivate static var sectionForNewsletterCTA: Component {
    Element(name: "section") {
      Header {
        H2 {
          Text("Don't Let Your App ")
          Element(name: "em") { Text("Fall Behind") }
        }
      }
      Main {
        Paragraph {
          Text(
            // swiftlint:disable:next line_length
            "Stay informed about the latest developments in the world of Swift App Development and what they could mean for your business."
          )
        }
      }
      Footer {
        Link("Subscribe Now", url: "/newsletters")
      }
    }.class("newsletter-cta")
  }

  // MARK: - Latest Articles

  fileprivate static func sectionForLatestArticles(
    basedOn context: PublishingContext<BrightDigitSite>
  ) -> Component {
    let latestArticles: [IndexArticle] = context.sections.compactMap(\.items.first)
      .filter(\.isAvailable)

    return Element(name: "section") {
      Header {
        H2("Latest")
      }
      Element(name: "ol") {
        for article in latestArticles {
          Self.latestArticle(article)
        }
      }
    }.id("posts")
  }

  // MARK: - ListContext

  fileprivate static func makeService(
    title: String, imageSrc: String, imageAlt: String, paragraph: String, linkID: String
  ) -> Component {
    ListItem {
      Header {
        H3 {
          Link(title, url: "/services#\(linkID)")
        }
        Image(url: imageSrc, description: imageAlt)
      }
      Main {
        Paragraph { Text(paragraph) }
      }
    }
  }
}
