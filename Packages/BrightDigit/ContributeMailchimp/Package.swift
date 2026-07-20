// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeMailchimp",
  // macOS 15 matches the root / Publish stack (Synchronization.Mutex).
  // iOS/tvOS/watchOS floors match Spinetail (iOS/tvOS 16, watchOS 9).
  platforms: [
    .macOS(.v15),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9)
  ],
  products: [
    .library(
      name: "ContributeMailchimp",
      targets: ["ContributeMailchimp"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/brightdigit/Contribute.git",
      branch: "brightdigit-com-260621"
    ),
    .package(
      url: "https://github.com/brightdigit/Spinetail.git",
      branch: "brightdigit-com-260621"
    )
  ],
  targets: [
    .target(
      name: "ContributeMailchimp",
      dependencies: [
        "Contribute",
        .product(name: "Spinetail", package: "Spinetail")
      ]
    ),
    .testTarget(
      name: "ContributeMailchimpTests",
      dependencies: ["ContributeMailchimp"]
    )
  ]
)
