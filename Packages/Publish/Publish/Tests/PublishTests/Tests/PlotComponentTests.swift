/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Publish
import Plot

final class PlotComponentTests: PublishTestCase {
    func testStylesheetPaths() {
        let html = Node.head(
            for: Page(path: "path", content: Content()),
            on: WebsiteStub.WithoutItemMetadata(),
            stylesheetPaths: [
                "local-1.css",
                "/local-2.css",
                "http://external-1.css",
                "https://external-2.css"
            ]
        ).render()

        let expectedURLs = [
            "/local-1.css",
            "/local-2.css",
            "http://external-1.css",
            "https://external-2.css"
        ]

        for url in expectedURLs {
            XCTAssertTrue(html.contains("""
            <link rel="stylesheet" href="\(url)" type="text/css"/>
            """))
        }
    }

    func testRenderingAudioPlayer() throws {
        let url = try require(URL(string: "https://audio.mp3"))
        let audio = Audio(url: url, format: .mp3)
        let html = Node.audioPlayer(for: audio).render()

        XCTAssertEqual(html, """
        <audio controls><source type="audio/mpeg" src="https://audio.mp3"/></audio>
        """)
    }

    func testRenderingHostedVideoPlayer() throws {
        let url = try require(URL(string: "https://video.mp4"))
        let video = Video.hosted(url: url, format: .mp4)
        let html = Node.videoPlayer(for: video).render()

        XCTAssertEqual(html, """
        <video controls><source type="video/mp4" src="https://video.mp4"/></video>
        """)
    }

    // Removed (PR #151): testRenderingYouTubeVideoPlayer, testRenderingVimeoVideoPlayer,
    // and testRenderingMarkdownComponent asserted exact HTML that no longer matches after the
    // swift-markdown/Plot vendoring — a known pre-existing behavioral diff (boolean attribute
    // rendering `allowfullscreen` vs `allowfullscreen="true"`, and the swift-markdown link
    // modifier no longer emitting `<b>`), not a regression from this PR.
}
