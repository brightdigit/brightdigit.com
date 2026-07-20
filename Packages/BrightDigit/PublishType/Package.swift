// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "PublishType",
  // Files (via Publish) needs iOS 18 / tvOS 18 / watchOS 11 for Synchronization.Mutex.
  platforms: [
    .macOS(.v15),
    .iOS(.v18),
    .tvOS(.v18),
    .watchOS(.v11)
  ],
  products: [
    .library(
      name: "PublishType",
      targets: ["PublishType"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/brightdigit/Publish.git",
      branch: "brightdigit-com-260406"
    )
  ],
  targets: [
    .target(
      name: "PublishType",
      dependencies: [
        .product(name: "Publish", package: "Publish")
      ]
    ),
    .testTarget(
      name: "PublishTypeTests",
      dependencies: ["PublishType"]
    )
  ]
)
