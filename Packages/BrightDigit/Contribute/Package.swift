// swift-tools-version: 5.8
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "Contribute",
  platforms: [.macOS(.v12)],
  products: [
    .library(
      name: "Contribute",
      targets: ["Contribute"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/jpsim/Yams.git",
      from: "4.0.4"
    )
  ],
  targets: [
    .target(
      name: "Contribute",
      dependencies: ["Yams"]
    ),
    .testTarget(
      name: "ContributeTests",
      dependencies: ["Contribute"]
    )
  ]
)
