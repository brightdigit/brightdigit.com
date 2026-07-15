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
        .package(path: "../Ink"),
        .package(path: "../Plot"),
        .package(path: "../Files")
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
