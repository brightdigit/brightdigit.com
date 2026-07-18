// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeYouTube",
  // Matches the root package floor (raised to .v15 for issue #44); the vendored
  // Publish stack also requires macOS 15 (Synchronization.Mutex).
  platforms: [.macOS(.v15)],
  products: [
    .library(
      name: "ContributeYouTube",
      targets: ["ContributeYouTube"]
    )
  ],
  dependencies: [
    .package(name: "Contribute", path: "../../BrightDigit/Contribute"),
    .package(name: "SwiftTube", path: "../../BrightDigit/SwiftTube")
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
