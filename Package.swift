// swift-tools-version:6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable explicit_top_level_acl
// swiftlint:disable prefixed_toplevel_constant
// swiftlint:disable explicit_acl

import PackageDescription

let package = Package(
  name: "BrightDigit",
  platforms: [
    // Raised from .v13 for issue #44: ConfigKeyKit 1.0.0-beta.2 requires macOS 15.
    // Deploy target is Linux (no platform floor), so this only affects local
    // macOS development/builds. See Documentation/Migration/44-config-migration.md.
    .macOS(.v15)
  ],
  products: [
    .executable(
      name: "brightdigitwg",
      targets: ["brightdigitwg"]
    ),
    .library(name: "ContributeMailchimp", targets: ["ContributeMailchimp"]),
    .library(name: "BrightDigitPodcast", targets: ["BrightDigitPodcast"]),
    .library(name: "ContributeYouTube", targets: ["ContributeYouTube"]),
    .library(name: "ContributeRSS", targets: ["ContributeRSS"]),
    .library(name: "PublishType", targets: ["PublishType"])
  ],
  dependencies: [
    .package(path: "Packages/Publish/Publish"),

    .package(path: "Packages/Publish/SplashPublishPlugin"),
    .package(path: "Packages/BrightDigit/YoutubePublishPlugin"),
    .package(path: "Packages/Plugins/ReadingTimePublishPlugin"),

    .package(path: "Packages/BrightDigit/SwiftTube"),
    .package(path: "Packages/BrightDigit/Spinetail"),
    .package(path: "Packages/BrightDigit/SyndiKit"),
    // .package(url: "https://github.com/BrightDigit/Options.git", from: "0.2.0"),
    .package(path: "Packages/BrightDigit/NPMPublishPlugin"),
    .package(path: "Packages/BrightDigit/Contribute"),
    .package(path: "Packages/BrightDigit/ContributeWordPress"),
    .package(path: "Packages/BrightDigit/TransistorPublishPlugin"),

    .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.0"),
    .package(url: "https://github.com/brightdigit/ConfigKeyKit.git", exact: "1.0.0-beta.2"),
    .package(
      url: "https://github.com/apple/swift-configuration",
      from: "1.0.0",
      traits: [.defaults, "CommandLineArguments"]
    )
    // #40: swift-markdown is the Publish markdown front end — it replaced Ink's
    // hand-written `Reader` parser inside the vendored `Ink` package, which
    // declares its own swift-markdown dependency (pinned to `branch: "main"`) and
    // retains its HTML emitter + public API. That transitive dependency pins the
    // revision for the whole workspace, so no root-level declaration is needed
    // here (a redundant one is "not used by any target" and SwiftPM warns on it).
  ],
  targets: [
    .executableTarget(
      name: "brightdigitwg",
      dependencies: ["BrightDigitArgs"]
    ),
    .target(
      name: "BrightDigitArgs",
      dependencies: [
        "BrightDigitSite",
        "BrightDigitPodcast",
        "ContributeYouTube",
        "ContributeRSS",
        "ContributeMailchimp",
        "ContributeWordPress",
        .product(name: "Spinetail", package: "Spinetail"),
        .product(name: "ConfigKeyKit", package: "ConfigKeyKit"),
        .product(name: "Configuration", package: "swift-configuration"),
      ]
    ),
    .target(
      name: "BrightDigitSite",
      dependencies: [
        "Publish",
        "SplashPublishPlugin",
        "YoutubePublishPlugin",
        "ReadingTimePublishPlugin",
        // "Options",
        "PublishType",
        "TransistorPublishPlugin",
        "NPMPublishPlugin"
      ]
    ),
    .target(
      name: "BrightDigitPodcast",
      dependencies: ["ContributeYouTube", "ContributeRSS"]
    ),
    .target(
      name: "ContributeMailchimp",
      dependencies: [
        "Contribute",
        .product(name: "Spinetail", package: "Spinetail")
      ]
    ),
    .target(
      name: "ContributeYouTube",
      dependencies: ["Contribute", "SwiftTube"]
    ),
    .target(
      name: "ContributeRSS",
      dependencies: ["Contribute", "SyndiKit"]
    ),
    .target(
      name: "PublishType",
      dependencies: [
        "Publish"
      ]
    ),
    .testTarget(
      name: "BrightDigitSiteTests",
      dependencies: [
        "Yams",
        "BrightDigitSite"
      ]
    ),
    .testTarget(
      name: "BrightDigitArgsTests",
      dependencies: [
        "BrightDigitArgs",
        "BrightDigitPodcast"
      ]
    )
  ]
)
