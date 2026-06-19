// swift-tools-version:5.5

/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "Publish",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "Publish", targets: ["Publish"])
    ],
    dependencies: [
        .package(path: "../Ink"),
        .package(path: "../Plot"),
        .package(path: "../Files"),
        .package(path: "../Codextended"),
        .package(path: "../Sweep"),
        .package(path: "../CollectionConcurrencyKit")
    ],
    targets: [
        .target(
            name: "Publish",
            dependencies: [
                "Ink", "Plot", "Files", "Codextended",
                "Sweep", "CollectionConcurrencyKit"
            ]
        ),
        .testTarget(
            name: "PublishTests",
            dependencies: ["Publish"]
        )
    ]
)
