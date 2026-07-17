// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "PublishType",
  platforms: [.macOS(.v15)],
  products: [
    .library(
      name: "PublishType",
      targets: ["PublishType"]
    )
  ],
  dependencies: [
    .package(path: "../../Publish/Publish")
  ],
  targets: [
    .target(
      name: "PublishType",
      dependencies: [
        .product(name: "Publish", package: "Publish")
      ]
    )
  ]
)
