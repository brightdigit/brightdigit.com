//
//  Testimonial+AssetHealthTG.swift
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

extension Testimonial {
  internal static let tomAssetHealth: Self = .init(
    id: 3,
    fullName: "Tom Grube",
    title: "Senior Software Engineer at Asset Health",
    fullQuote:
      // swiftlint:disable:next line_length
      "We contracted Leo to help build our iOS app. The deadline was tight and he developed the features with impressive speed. He has thorough knowledge of all aspects of building a native app, from UI/UX design to API development and consumption. The thing that impressed me the most about Leo was his flexibility and understanding of the complexities of a large project, especially when requirements are not always well defined or when changing requirements causes rework. We hope to work with Leo again in the future!",
    // swiftlint:disable indentation_width line_length
    briefQuote: """
          We contracted Leo to help build our iOS app. The deadline was tight and he developed the features with impressive speed. He has thorough knowledge of all aspects of building a native app, from UI/UX design to API development and consumption. The thing that impressed me the most about Leo was his flexibility and understanding of the complexities of a large project.
      """
    // swiftlint:enable indentation_width line_length
  )
}
