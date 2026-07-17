// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeYouTube",
  platforms: [.macOS(.v13)],
  products: [
    .library(
      name: "ContributeYouTube",
      targets: ["ContributeYouTube"]
    )
  ],
  dependencies: [
    .package(path: "../../BrightDigit/Contribute"),
    .package(path: "../../BrightDigit/SwiftTube")
  ],
  targets: [
    .target(
      name: "ContributeYouTube",
      dependencies: [
        "Contribute",
        .product(name: "SwiftTube", package: "SwiftTube")
      ]
    )
  ]
)
