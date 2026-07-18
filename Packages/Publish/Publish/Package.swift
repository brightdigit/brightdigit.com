// swift-tools-version:6.4

/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "Publish",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Publish", targets: ["Publish"])
    ],
    dependencies: [
        .package(url: "https://github.com/brightdigit/Ink.git", revision: "84bf8e119acfe79372a2aed07d07d4e5ea1ee2c5"),
        .package(url: "https://github.com/brightdigit/Plot.git", revision: "daa8daa44f8eb0a1865085ee0f36ca02aa16b7f4"),
        .package(url: "https://github.com/brightdigit/Files.git", revision: "ec08c20088b17630ada2069e5021fd1bdf85cc75")
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
