// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeMailchimp",
  platforms: [.macOS(.v13)],
  products: [
    .library(
      name: "ContributeMailchimp",
      targets: ["ContributeMailchimp"]
    )
  ],
  dependencies: [
    .package(path: "../../BrightDigit/Contribute"),
    .package(path: "../../BrightDigit/Spinetail")
  ],
  targets: [
    .target(
      name: "ContributeMailchimp",
      dependencies: [
        "Contribute",
        .product(name: "Spinetail", package: "Spinetail")
      ]
    )
  ]
)
