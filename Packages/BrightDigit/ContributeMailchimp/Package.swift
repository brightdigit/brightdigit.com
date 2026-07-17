// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeMailchimp",
  // Matches the root package floor (raised to .v15 for issue #44); the vendored
  // Publish stack also requires macOS 15 (Synchronization.Mutex).
  platforms: [.macOS(.v15)],
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
