// swift-tools-version:6.4

/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "Ink",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Ink", targets: ["Ink"])
    ],
    dependencies: [
        // #40: swift-markdown replaces Ink's hand-written `Reader` parser as the
        // markdown front end. Its product/module is named `Markdown`, which collides
        // with Ink's own `Markdown` value type (and Publish's `Markdown` component).
        // The collision is resolved at the use site with the Swift 6.4 module selector
        // (`Markdown::Type`) — see `MarkdownVisitor`/`InlineHTMLRenderer` (per CLAUDE.md:
        // resolve collisions in the call site, never by renaming our own types).
        // Pinned to `branch: "main"` to match the top-level manifest: swift-markdown
        // has no semver tags compatible with the pre-release Swift 6.4 toolchain.
        .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main")
    ],
    targets: [
        .target(
            name: "Ink",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown")
            ]
        ),
        .testTarget(name: "InkTests", dependencies: ["Ink"])
    ]
)
