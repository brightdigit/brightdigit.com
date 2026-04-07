// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "ReadingTimePublishPlugin",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "ReadingTimePublishPlugin",
            targets: ["ReadingTimePublishPlugin"]
        ),
    ],
    dependencies: [
        .package(path: "../../Publish/Publish"),
    ],
    targets: [
        .target(
            name: "ReadingTimePublishPlugin",
            dependencies: ["Publish"]
        ),
        .testTarget(
            name: "ReadingTimePublishPluginTests",
            dependencies: ["ReadingTimePublishPlugin"]
        ),
    ]
)
