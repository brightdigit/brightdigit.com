/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Plot
import Publish
import XCTest

extension HTMLGenerationTests {
  internal func testAlwaysGeneratingIndexPageForAllSections() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>(
      makeSectionHTML: { section, _ in
        HTML(.body(.text(section.id.rawValue)))
      }
    )

    try publishWebsite(
      using: Theme(htmlFactory: htmlFactory),
      expectedHTML: [
        "one/index.html": "one",
        "two/index.html": "two",
        "three/index.html": "three",
        "custom-raw-value/index.html": "custom-raw-value",
      ]
    )
  }

  internal func testNotGeneratingTagHTMLForIncompatibleTheme() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>(
      makeTagListHTML: nil,
      makeTagDetailsHTML: nil
    )

    try publishWebsite(
      using: Theme(htmlFactory: htmlFactory),
      additionalSteps: [
        .addItem(Item.stub(withPath: "item").setting(\.tags, to: ["tag"]))
      ],
      expectedHTML: [
        "index.html": "",
        "one/index.html": "",
        "two/index.html": "",
        "three/index.html": "",
        "custom-raw-value/index.html": "",
        "one/item/index.html": "",
      ],
      allowlistedOutputFiles: false
    )
  }

  internal func testNotGeneratingTagHTMLWhenDisabled() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>()

    var site = WebsiteStub.WithoutItemMetadata()
    site.tagHTMLConfig = nil

    try publishWebsite(
      site,
      using: Theme(htmlFactory: htmlFactory),
      additionalSteps: [
        .addItem(Item.stub(withPath: "item").setting(\.tags, to: ["tag"]))
      ],
      expectedHTML: [
        "index.html": "",
        "one/index.html": "",
        "two/index.html": "",
        "three/index.html": "",
        "custom-raw-value/index.html": "",
        "one/item/index.html": "",
      ],
      allowlistedOutputFiles: false
    )
  }

  internal func testGeneratingStandAloneHTMLFiles() throws {
    let htmlFactory = HTMLFactoryMock<WebsiteStub.WithoutItemMetadata>()
    let folder = try Folder.createTemporary()
    let theme = Theme(htmlFactory: htmlFactory)

    try publishWebsite(
      in: folder,
      using: [
        .addItem(Item.stub(withPath: "item").setting(\.tags, to: ["tag"])),
        .addItem(
          Item.stub(withPath: "rawValueItem", sectionID: .customRawValue).setting(
            \.tags, to: ["tag"]
          )
        ),
        .generateHTML(withTheme: theme, fileMode: .standAloneFiles),
      ]
    )

    try verifyOutput(
      in: folder,
      expectedHTML: [
        "index.html": "",
        "one/index.html": "",
        "two/index.html": "",
        "three/index.html": "",
        "custom-raw-value/index.html": "",
        "one/item.html": "",
        "custom-raw-value/rawValueItem.html": "",
        "tags/index.html": "",
        "tags/tag.html": "",
      ],
      allowlistedFiles: false
    )
  }

  internal func testFoundationTheme() throws {
    let folder = try Folder.createTemporary()

    try publishWebsite(
      in: folder,
      using: [
        .addMarkdownFiles(),
        .generateHTML(withTheme: .foundation),
      ],
      content: [
        "one/index.md": "# SectionTitle",
        "one/item.md": """
        ---
        tags: tagA, tagB
        ---
        # ItemTitle
        """,
        "page.md": "# PageTitle",
      ]
    )

    let siteIndex = try folder.file(at: "Output/index.html")
    XCTAssertTrue(try siteIndex.readAsString().contains("WebsiteName"))

    let sectionIndex = try folder.file(at: "Output/one/index.html")
    XCTAssertTrue(try sectionIndex.readAsString().contains("SectionTitle"))

    let item = try folder.file(at: "Output/one/item/index.html")
    XCTAssertTrue(try item.readAsString().contains("ItemTitle"))

    let page = try folder.file(at: "Output/page/index.html")
    XCTAssertTrue(try page.readAsString().contains("PageTitle"))

    let tagList = try folder.file(at: "Output/tags/index.html")
    let tagListHTML = try tagList.readAsString()
    XCTAssertTrue(tagListHTML.contains("tagA"))
    XCTAssertTrue(tagListHTML.contains("tagB"))

    let tagDetails = try folder.file(at: "Output/tags/taga/index.html")
    XCTAssertTrue(try tagDetails.readAsString().contains("tagA"))
  }
}
