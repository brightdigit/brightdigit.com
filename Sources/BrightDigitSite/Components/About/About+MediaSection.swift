//
//  About+MediaSection.swift
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

extension About {
  /// About page media+text section (video header, optional H2, body paragraphs).
  internal struct MediaSection: Component {
    internal enum BodyContent {
      case plainText(String)
      case markdown(para1: String, para2: String, para3: String)
    }

    internal let imageSrc: String
    internal let loop: Bool
    internal let header: String?
    internal let content: BodyContent

    internal var body: Component {
      Element(name: "section") {
        Header {
          AutoplayVideo(src: imageSrc, loop: loop)
        }
        Main {
          if let header {
            Header {
              H2("\(header)")
            }
          }
          Main {
            switch content {
            case .plainText(let text):
              Paragraph { Text("\(text)") }
            case let .markdown(para1, para2, para3):
              Node<HTML.BodyContext>.markdown(para1)
              Node<HTML.BodyContext>.markdown(para2)
              Node<HTML.BodyContext>.markdown(para3)
            }
          }
        }
      }
    }

    /// Plain-text body, no section H2 (former `leftImageWithRightTextNoHeader`).
    internal init(imageSrc: String, text: String, loop: Bool = false) {
      self.imageSrc = imageSrc
      self.loop = loop
      self.header = nil
      self.content = .plainText(text)
    }

    /// Markdown paragraphs with section H2 (former leftText/leftImage header helpers).
    internal init(
      imageSrc: String,
      header: String,
      para1: String,
      para2: String,
      para3: String,
      loop: Bool = true
    ) {
      self.imageSrc = imageSrc
      self.loop = loop
      self.header = header
      self.content = .markdown(para1: para1, para2: para2, para3: para3)
    }
  }
}
