// swift-tools-version:6.4

import PackageDescription

let package = Package(
    name: "ReadingTimePublishPlugin",
    platforms: [.macOS(.v15)],
    products: [
        .library(
            name: "ReadingTimePublishPlugin",
            targets: ["ReadingTimePublishPlugin"]
        ),
    ],
    dependencies: [
        .package(name: "Publish", path: "../../Publish/Publish"),
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
