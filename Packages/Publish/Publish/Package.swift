// swift-tools-version:6.4

/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "Publish",
    // Files requires iOS 18 / tvOS 18 / watchOS 11 (Synchronization.Mutex).
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(name: "Publish", targets: ["Publish"])
    ],
    dependencies: [
        .package(url: "https://github.com/brightdigit/Ink.git", revision: "443d80e352ec3cdd07eed54bd84a9789378d8665"),
        .package(url: "https://github.com/brightdigit/Plot.git", revision: "daa8daa44f8eb0a1865085ee0f36ca02aa16b7f4"),
        .package(url: "https://github.com/brightdigit/Files.git", revision: "2983eb8104844a0e874bb375356e690e31d2716e")
    ],
    targets: [
        .target(
            name: "Publish",
            dependencies: [
                "Ink", "Plot", "Files"
            ]
        ),
        .testTarget(
            name: "PublishTests",
            dependencies: ["Publish"]
        )
    ]
)
