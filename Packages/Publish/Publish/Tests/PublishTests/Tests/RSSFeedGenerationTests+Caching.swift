/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Publish
import XCTest

extension RSSFeedGenerationTests {
  internal func testReusingPreviousFeedIfNoItemsWereModified() throws {
    let folder = try Folder.createTemporary()
    let contentFile = try folder.createFile(at: "Content/one/item.md")

    try generateFeed(in: folder)
    let feedA = try folder.file(at: "Output/feed.rss").readAsString()

    let newDate = Date().addingTimeInterval(60 * 60)
    try generateFeed(in: folder, date: newDate)
    let feedB = try folder.file(at: "Output/feed.rss").readAsString()

    XCTAssertEqual(feedA, feedB)

    try contentFile.append("New content")
    try generateFeed(in: folder, date: newDate)
    let feedC = try folder.file(at: "Output/feed.rss").readAsString()

    XCTAssertNotEqual(feedB, feedC)
  }

  internal func testNotReusingPreviousFeedIfConfigChanged() throws {
    let folder = try Folder.createTemporary()
    try folder.createFile(at: "Content/one/item.md")

    try generateFeed(in: folder)
    let feedA = try folder.file(at: "Output/feed.rss").readAsString()

    let newConfig = RSSFeedConfiguration(ttlInterval: 5_000)
    let newDate = Date().addingTimeInterval(60 * 60)
    try generateFeed(in: folder, config: newConfig, date: newDate)
    let feedB = try folder.file(at: "Output/feed.rss").readAsString()

    XCTAssertNotEqual(feedA, feedB)
  }

  internal func testNotReusingPreviousFeedIfItemWasAdded() throws {
    let folder = try Folder.createTemporary()
    let itemA = Item.stub()
    let itemB = Item.stub().setting(\.lastModified, to: itemA.lastModified)

    try generateFeed(
      in: folder,
      generationSteps: [
        .addItem(itemA)
      ]
    )

    let feedA = try folder.file(at: "Output/feed.rss").readAsString()

    try generateFeed(
      in: folder,
      generationSteps: [
        .addItem(itemA),
        .addItem(itemB),
      ]
    )

    let feedB = try folder.file(at: "Output/feed.rss").readAsString()
    XCTAssertNotEqual(feedA, feedB)
  }
}
