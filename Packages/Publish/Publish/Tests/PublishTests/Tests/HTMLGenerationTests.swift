/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Plot
import Publish
import XCTest

internal final class HTMLGenerationTests: PublishTestCase {
  internal func testGeneratingIndexHTML() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>(
      makeIndexHTML: { content, _ in
        HTML(.body(.text(content.title))).node
      }
    )

    try publishWebsite(
      using: Theme(htmlFactory: htmlFactory),
      content: ["index.md": "# Hello, world!"],
      expectedHTML: ["index.html": "Hello, world!"]
    )
  }

  internal func testGeneratingSectionHTML() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>(
      makeSectionHTML: { section, _ in
        HTML(.body(.text(section.title))).node
      }
    )

    try publishWebsite(
      using: Theme(htmlFactory: htmlFactory),
      content: [
        "one/index.md": "# Section 1",
        "two/index.md": "# Section 2",
      ],
      expectedHTML: [
        "one/index.html": "Section 1",
        "two/index.html": "Section 2",
      ]
    )
  }

  internal func testGeneratingItemHTML() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>(
      makeItemHTML: { item, _ in
        HTML(
          .body(
            .unwrap(item.audio?.url, { .text($0.absoluteString) }),
            .text(" "),
            .text(item.title)
          )
        ).node
      }
    )

    try publishWebsite(
      using: Theme(htmlFactory: htmlFactory),
      content: [
        "one/a.md": """
        ---
        audio.url: a.mp3
        ---
        # A
        """,
        "two/b.md": """
        ---
        audio.url: b.mp3
        ---
        # B
        """,
      ],
      expectedHTML: [
        "one/a/index.html": "a.mp3 A",
        "two/b/index.html": "b.mp3 B",
      ]
    )
  }

  internal func testGeneratingNestedItemHTML() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>(
      makeItemHTML: { item, _ in
        HTML(.body(.text(item.title))).node
      }
    )

    try publishWebsite(
      using: Theme(htmlFactory: htmlFactory),
      content: [
        "one/2019/12/a.md": """
        # A
        """,
        "two/2020/01/b.md": """
        # B
        """,
      ],
      expectedHTML: [
        "one/2019/12/a/index.html": "A",
        "two/2020/01/b/index.html": "B",
      ]
    )
  }

  internal func testGeneratingPageHTML() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>(
      makePageHTML: { page, _ in
        HTML(.body(.text(page.title))).node
      }
    )

    try publishWebsite(
      using: Theme(htmlFactory: htmlFactory),
      content: [
        "page1.md": "# Page 1",
        "page2.md": "# Page 2",
      ],
      additionalSteps: [
        .addPage(
          Page(
            path: "path/to/page3",
            content: Content(title: "Page 3")
          )
        )
      ],
      expectedHTML: [
        "page1/index.html": "Page 1",
        "page2/index.html": "Page 2",
        "path/to/page3/index.html": "Page 3",
      ]
    )
  }

  internal func testGeneratingTagHTML() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>(
      makeTagListHTML: { page, _ in
        HTML(
          .body(
            .ul(
              .forEach(page.tags.sorted()) {
                .li(.text($0.string))
              }
            )
          )
        ).node
      },
      makeTagDetailsHTML: { page, _ in
        HTML(.body(.text(page.tag.string))).node
      }
    )

    try publishWebsite(
      using: Theme(htmlFactory: htmlFactory),
      content: [
        "one/a.md": """
        ---
        tags: tag 1
        ---
        """,
        "two/b.md": """
        ---
        tags: tag 2, tag 3😉
        ---
        """,
      ],
      expectedHTML: [
        "tags/index.html": """
        <ul><li>tag 1</li><li>tag 2</li><li>tag 3😉</li></ul>
        """,
        "tags/tag-1/index.html": "tag 1",
        "tags/tag-2/index.html": "tag 2",
        "tags/tag-3/index.html": "tag 3😉",
        "one/a/index.html": "",
        "two/b/index.html": "",
      ]
    )
  }

  internal func testCleaningUpOldHTMLFiles() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>(
      makePageHTML: { page, _ in
        HTML(.body(.text(page.title))).node
      }
    )

    let folder = try Folder.createTemporary()

    try publishWebsite(
      in: folder,
      using: Theme(htmlFactory: htmlFactory),
      content: [
        "first.md": "# First"
      ],
      expectedHTML: [
        "first/index.html": "First"
      ]
    )

    try publishWebsite(
      in: folder,
      using: Theme(htmlFactory: htmlFactory),
      content: [
        "second.md": "# Second"
      ],
      expectedHTML: [
        "second/index.html": "Second"
      ]
    )
  }
}
