// swift-tools-version:6.4

/**
 *  Files
 *  Copyright (c) John Sundell 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "Files",
    // Mutex (Synchronization) requires iOS 18 / tvOS 18 / watchOS 11.
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(name: "Files", targets: ["Files"])
    ],
    targets: [
        .target(
            name: "Files",
            path: "Sources"
        ),
        .testTarget(
            name: "FilesTests",
            dependencies: ["Files"]
        )
    ]
)
