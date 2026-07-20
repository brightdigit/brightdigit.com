// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeYouTube",
  // macOS 15 matches the root / Publish stack (Synchronization.Mutex).
  // iOS/tvOS/watchOS floors match SwiftTube (iOS/tvOS 16, watchOS 9).
  platforms: [
    .macOS(.v15),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9)
  ],
  products: [
    .library(
      name: "ContributeYouTube",
      targets: ["ContributeYouTube"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/brightdigit/Contribute.git",
      branch: "brightdigit-com-260621"
    ),
    .package(
      url: "https://github.com/brightdigit/SwiftTube.git",
      branch: "brightdigit-com-260621"
    )
  ],
  targets: [
    .target(
      name: "ContributeYouTube",
      dependencies: [
        "Contribute",
        .product(name: "SwiftTube", package: "SwiftTube")
      ]
    ),
    .testTarget(
      name: "ContributeYouTubeTests",
      dependencies: ["ContributeYouTube"]
    )
  ]
)
