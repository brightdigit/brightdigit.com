// swift-tools-version:6.4

import PackageDescription

let package = Package(
    name: "ReadingTimePublishPlugin",
    // Files (via Publish) needs iOS 18 / tvOS 18 / watchOS 11 for Synchronization.Mutex.
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "ReadingTimePublishPlugin",
            targets: ["ReadingTimePublishPlugin"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/brightdigit/Publish.git",
            branch: "brightdigit-com-260406"
        ),
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
