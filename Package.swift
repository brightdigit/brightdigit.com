// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable explicit_top_level_acl
// swiftlint:disable prefixed_toplevel_constant
// swiftlint:disable explicit_acl

import PackageDescription

let package = Package(
  name: "BrightDigit",
  platforms: [
    .macOS(.v12)
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
    //.package(url: "https://github.com/BrightDigit/Options.git", from: "0.2.0"),
    .package(path: "Packages/BrightDigit/NPMPublishPlugin"),
    .package(path: "Packages/BrightDigit/Contribute"),
    .package(path: "Packages/BrightDigit/ContributeWordPress"),
    .package(path: "Packages/BrightDigit/TransistorPublishPlugin"),

    .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.3"),
    .package(url: "https://github.com/tid-kijyun/Kanna.git", from: "5.2.2"),
    .package(url: "https://github.com/eneko/MarkdownGenerator.git", from: "0.4.0")
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
      ]
    ),
    .target(
      name: "BrightDigitSite",
      dependencies: [
        "Publish",
        "SplashPublishPlugin",
        "YoutubePublishPlugin",
        "ReadingTimePublishPlugin",
        //"Options",
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
        "Kanna",
        "Contribute",
        "MarkdownGenerator",
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
