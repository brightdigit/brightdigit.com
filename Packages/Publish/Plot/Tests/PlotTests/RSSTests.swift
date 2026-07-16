/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot
import XCTest

internal final class RSSTests: XCTestCase {
  internal func testEmptyFeed() {
    let feed = RSS()
    assertEqualRSSFeedContent(feed, "")
  }

  internal func testFeedTitle() {
    let feed = RSS(.title("MyPodcast"))
    assertEqualRSSFeedContent(feed, "<title>MyPodcast</title>")
  }

  internal func testFeedDescription() {
    let feed = RSS(.description("Description"))
    assertEqualRSSFeedContent(feed, "<description>Description</description>")
  }

  internal func testFeedDescriptionWithHTMLContent() {
    let feed = RSS(
      .description(
        .p(
          .text("Description with "),
          .em("emphasis"),
          .text(".")
        )
      )
    )
    assertEqualRSSFeedContent(
      feed, "<description><![CDATA[<p>Description with <em>emphasis</em>.</p>]]></description>"
    )
  }

  internal func testFeedURL() {
    let feed = RSS(.link("url.com"))
    assertEqualRSSFeedContent(feed, "<link>url.com</link>")
  }

  internal func testFeedAtomLink() {
    let feed = RSS(.atomLink("url.com"))
    assertEqualRSSFeedContent(
      feed,
      """
      <atom:link href="url.com" rel="self" type="application/rss+xml"/>
      """
    )
  }

  internal func testFeedLanguage() {
    let feed = RSS(.language(.usEnglish))
    assertEqualRSSFeedContent(feed, "<language>en-us</language>")
  }

  internal func testFeedTTL() {
    let feed = RSS(.ttl(200))
    assertEqualRSSFeedContent(feed, "<ttl>200</ttl>")
  }

  internal func testFeedPublicationDate() throws {
    let stubs = try Date.makeStubs(withFormattingStyle: .rss)
    let feed = RSS(.pubDate(stubs.date, timeZone: stubs.timeZone))
    assertEqualRSSFeedContent(feed, "<pubDate>\(stubs.expectedString)</pubDate>")
  }

  internal func testFeedLastBuildDate() throws {
    let stubs = try Date.makeStubs(withFormattingStyle: .rss)
    let feed = RSS(.lastBuildDate(stubs.date, timeZone: stubs.timeZone))
    assertEqualRSSFeedContent(feed, "<lastBuildDate>\(stubs.expectedString)</lastBuildDate>")
  }

  internal func testItemGUID() {
    let feed = RSS(
      .item(.guid("123")),
      .item(.guid("url.com", .isPermaLink(true))),
      .item(.guid("123", .isPermaLink(false)))
    )

    assertEqualRSSFeedContent(
      feed,
      """
      <item><guid>123</guid></item>\
      <item><guid isPermaLink="true">url.com</guid></item>\
      <item><guid isPermaLink="false">123</guid></item>
      """
    )
  }

  internal func testItemTitle() {
    let feed = RSS(.item(.title("Title")))
    assertEqualRSSFeedContent(feed, "<item><title>Title</title></item>")
  }

  internal func testItemDescription() {
    let feed = RSS(.item(.description("Description")))
    assertEqualRSSFeedContent(
      feed,
      """
      <item><description>Description</description></item>
      """
    )
  }

  internal func testItemURL() {
    let feed = RSS(.item(.link("url.com")))
    assertEqualRSSFeedContent(feed, "<item><link>url.com</link></item>")
  }

  internal func testItemPublicationDate() throws {
    let stubs = try Date.makeStubs(withFormattingStyle: .rss)
    let feed = RSS(.item(.pubDate(stubs.date, timeZone: stubs.timeZone)))
    assertEqualRSSFeedContent(
      feed,
      """
      <item><pubDate>\(stubs.expectedString)</pubDate></item>
      """
    )
  }

  internal func testItemHTMLStringContent() {
    let feed = RSS(
      .item(
        .content(
          "<p>Hello</p><p>World &amp; Everyone!</p>"
        )
      )
    )

    assertEqualRSSFeedContent(
      feed,
      """
      <item>\
      <content:encoded>\
      <![CDATA[<p>Hello</p><p>World &amp; Everyone!</p>]]>\
      </content:encoded>\
      </item>
      """
    )
  }

  internal func testItemHTMLDSLContent() {
    let feed = RSS(
      .item(
        .content(.h1("Title"))
      )
    )

    assertEqualRSSFeedContent(
      feed,
      """
      <item>\
      <content:encoded>\
      <![CDATA[<h1>Title</h1>]]>\
      </content:encoded>\
      </item>
      """
    )
  }
}
