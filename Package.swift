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
    .package(url: "https://github.com/johnsundell/Publish.git", from: "0.9.0"),

    .package(url: "https://github.com/johnsundell/SplashPublishPlugin.git", from: "0.2.0"),
    .package(url: "https://github.com/tanabe1478/YoutubePublishPlugin.git", from: "1.0.1"),
    .package(url: "https://github.com/alexito4/ReadingTimePublishPlugin.git", from: "0.3.0"),
    .package(url: "https://github.com/johnsundell/ShellOut.git", from: "2.3.0"),

    .package(url: "https://github.com/BrightDigit/SwiftTube.git", from: "0.2.0-beta.5"),
    .package(url: "https://github.com/BrightDigit/Spinetail.git", from: "0.3.0"),
    .package(url: "https://github.com/BrightDigit/SyndiKit", from: "0.3.7"),
    //.package(url: "https://github.com/BrightDigit/Options.git", from: "0.2.0"),
    .package(url: "https://github.com/brightdigit/NPMPublishPlugin.git", from: "1.0.0"),
    .package(url: "https://github.com/brightdigit/Contribute.git", from: "1.0.0-alpha.5"),
    .package(url: "https://github.com/brightdigit/ContributeWordPress.git", from: "1.0.0"),
    .package(url: "https://github.com/brightdigit/TransistorPublishPlugin.git", from: "1.0.0"),

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

#if canImport(PackageConfig)
  import PackageConfig

  let requiredCoverage: Int = 30

  let config = PackageConfiguration([
    "komondor": [
      "pre-push": [
        "swift test --enable-code-coverage --enable-test-discovery",
        "swift run swift-test-codecov .build/debug/codecov/MistKit.json -v \(requiredCoverage)"
      ],
      "pre-commit": [
        "swift test --enable-code-coverage --enable-test-discovery --generate-linuxmain",
        "swift run swiftformat .",
        "swift run swiftlint autocorrect",
        "swift run sourcedocs generate build -cra",
        "git add .",
        "swift run swiftformat --lint .",
        "swift run swiftlint"
      ]
    ]
  ]).write()
#endif
