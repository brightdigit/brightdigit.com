// swift-tools-version:6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable explicit_top_level_acl
// swiftlint:disable prefixed_toplevel_constant
// swiftlint:disable explicit_acl

import PackageDescription

let package = Package(
  name: "BrightDigit",
  platforms: [
    // Raised from .v13 for issue #44: ConfigKeyKit 1.0.0-beta.1 requires macOS 15.
    // Deploy target is Linux (no platform floor), so this only affects local
    // macOS development/builds. See Documentation/Migration/44-config-migration.md.
    .macOS(.v15)
  ],
  products: [
    .executable(
      name: "brightdigitwg",
      targets: ["brightdigitwg"]
    ),
    .library(name: "Tagscriber", targets: ["Tagscriber"]),
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
    .package(url: "https://github.com/johnsundell/ShellOut.git", from: "2.3.0"),

    .package(path: "Packages/BrightDigit/SwiftTube"),
    .package(path: "Packages/BrightDigit/Spinetail"),
    .package(path: "Packages/BrightDigit/SyndiKit"),
    // .package(url: "https://github.com/BrightDigit/Options.git", from: "0.2.0"),
    .package(path: "Packages/BrightDigit/NPMPublishPlugin"),
    .package(path: "Packages/BrightDigit/Contribute"),
    .package(path: "Packages/BrightDigit/ContributeWordPress"),
    .package(path: "Packages/BrightDigit/TransistorPublishPlugin"),

    .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    .package(path: "Packages/BrightDigit/ConfigKeyKit"),
    .package(
      url: "https://github.com/apple/swift-configuration",
      from: "1.0.0",
      traits: [.defaults, "CommandLineArguments"]
    ),
    .package(url: "https://github.com/tid-kijyun/Kanna.git", from: "5.2.2"),
    .package(url: "https://github.com/eneko/MarkdownGenerator.git", from: "0.4.0"),
    // #40: swift-markdown is now the Publish markdown front end — it replaced Ink's
    // hand-written `Reader` parser inside the vendored `Ink` package (which declares its
    // own swift-markdown dependency and retains its HTML emitter + public API). Kept here
    // so the whole-workspace resolution pins the same revision.
    // Pinned to `branch: "main"` (standardizing with PR #86): swift-markdown has no
    // semver tags compatible with the pre-release Swift 6.4 toolchain, so the project
    // tracks main until a compatible tagged release exists.
    .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.7.0")

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
        "Tagscriber",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
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
      dependencies: ["Contribute", "Spinetail"]
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
      name: "Tagscriber",
      dependencies: [
        "SwiftSoup",
        "Contribute",
        .product(name: "Markdown", package: "swift-markdown"),
        "ShellOut"
      ]
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
    )
  ]
)
