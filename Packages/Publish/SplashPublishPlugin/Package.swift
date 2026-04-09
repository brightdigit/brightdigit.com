// swift-tools-version:5.6

/**
*  Splash plugin for Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "SplashPublishPlugin",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "SplashPublishPlugin",
            targets: ["SplashPublishPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../Publish"),
        .package(path: "../Splash")
    ],
    targets: [
        .target(
            name: "SplashPublishPlugin",
            dependencies: ["Splash", "Publish"]
        ),
        .testTarget(
            name: "SplashPublishPluginTests",
            dependencies: ["SplashPublishPlugin"]
        ),
    ]
)
