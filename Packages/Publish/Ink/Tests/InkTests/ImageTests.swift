/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class ImageTests: XCTestCase {
    // #40: under the swift-markdown front end a block consisting solely of an image is a
    // paragraph whose only child is the image, so it is wrapped in `<p>` (CommonMark) —
    // Ink's hand-written parser emitted the bare `<img>`.
    func testImageWithURL() {
        let html = MarkdownParser().html(from: "![](url)")
        XCTAssertEqual(html, #"<p><img src="url"/></p>"#)
    }

    // #40: a link/image reference definition (`[url]: …`) cannot interrupt a paragraph in
    // CommonMark, so when it directly follows the image on the next line the whole thing is
    // a single paragraph of literal text. (With a blank line between, swift-markdown
    // resolves the reference — see `testImageWithReferenceSeparatedByBlankLine`.)
    func testImageWithReference() {
        let html = MarkdownParser().html(from: """
        ![][url]
        [url]: https://swiftbysundell.com
        """)

        XCTAssertEqual(html, "<p>![][url] [url]: https://swiftbysundell.com</p>")
    }

    func testImageWithReferenceSeparatedByBlankLine() {
        let html = MarkdownParser().html(from: """
        ![][url]

        [url]: https://swiftbysundell.com
        """)

        XCTAssertEqual(html, #"<p><img src="https://swiftbysundell.com"/></p>"#)
    }

    func testImageWithURLAndAltText() {
        let html = MarkdownParser().html(from: "![Alt text](url)")
        XCTAssertEqual(html, #"<p><img src="url" alt="Alt text"/></p>"#)
    }

    func testImageWithReferenceAndAltText() {
        let html = MarkdownParser().html(from: """
        ![Alt text][url]

        [url]: swiftbysundell.com
        """)

        XCTAssertEqual(html, #"<p><img src="swiftbysundell.com" alt="Alt text"/></p>"#)
    }

    func testImageWithinParagraph() {
        let html = MarkdownParser().html(from: "Text ![](url) text")
        XCTAssertEqual(html, #"<p>Text <img src="url"/> text</p>"#)
    }
}

extension ImageTests {
    static var allTests: Linux.TestList<ImageTests> {
        return [
            ("testImageWithURL", testImageWithURL),
            ("testImageWithReference", testImageWithReference),
            ("testImageWithReferenceSeparatedByBlankLine", testImageWithReferenceSeparatedByBlankLine),
            ("testImageWithURLAndAltText", testImageWithURLAndAltText),
            ("testImageWithReferenceAndAltText", testImageWithReferenceAndAltText),
            ("testImageWithinParagraph", testImageWithinParagraph)
        ]
    }
}
