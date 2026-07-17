//
//  AboutBuilder.swift
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

internal struct AboutBuilder: PageBuilder {
  internal typealias WebsiteType = BrightDigitSite

  internal typealias LocationType = Page

  internal let description: String = Strings.About.ctaP1

  internal var imagePath: Path = "/media/about-us/graphic-attract.jpg"

  internal var bodyClasses: [String] { [] }

  @ComponentBuilder internal func main(
    forLocation _: LocationType, withContext _: PublishingContext<BrightDigitSite>
  ) -> Component {
    About.PageHeader()
    About.MediaSection(
      imageSrc: "/media/about-us/graphic-attract.webm",
      text: Strings.About.section1
    )
    About.MediaSection(
      imageSrc: "/media/about-us/opportunities.webm",
      header: Strings.About.whoWeAreTitle,
      para1: Strings.About.whoWeAreP1,
      para2: Strings.About.whoWeAreP2,
      para3: Strings.About.whoWeAreP3
    )
    About.MediaSection(
      imageSrc: "/media/about-us/communication.webm",
      header: Strings.About.workWithUsTitle,
      para1: Strings.About.workWithusP1,
      para2: Strings.About.workWithusP2,
      para3: Strings.About.workWithusP3
    )
    About.MediaSection(
      imageSrc: "/media/about-us/podcast.webm",
      header: Strings.About.helpingOthersTitle,
      para1: Strings.About.helpingOthersP1,
      para2: Strings.About.helpingOthersP2,
      para3: ""
    )
    About.CTASection()
  }
}
