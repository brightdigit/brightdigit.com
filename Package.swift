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
    // macOS development/builds.
    .macOS(.v15)
  ],
  products: [
    .executable(
      name: "brightdigitwg",
      targets: ["brightdigitwg"]
    ),
    .library(name: "BrightDigitPodcast", targets: ["BrightDigitPodcast"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/brightdigit/Publish.git",
      branch: "brightdigit-com-260406"
    ),

    .package(
      url: "https://github.com/brightdigit/YoutubePublishPlugin.git",
      branch: "brightdigit-com-260406"
    ),
    .package(
      url: "https://github.com/brightdigit/ReadingTimePublishPlugin.git",
      branch: "brightdigit-com-260406"
    ),

    .package(
      url: "https://github.com/brightdigit/TailwindKit.git",
      branch: "brightdigit-com-260717"
    ),
    .package(
      url: "https://github.com/brightdigit/Spinetail.git",
      branch: "brightdigit-com-260621"
    ),
    .package(
      url: "https://github.com/brightdigit/ButtondownKit.git",
      branch: "brightdigit-com-260621"
    ),
    .package(
      url: "https://github.com/brightdigit/SyndiKit.git",
      branch: "brightdigit-com-260621"
    ),
    // .package(url: "https://github.com/BrightDigit/Options.git", from: "0.2.0"),
    .package(
      url: "https://github.com/brightdigit/NPMPublishPlugin.git",
      branch: "brightdigit-com-260406"
    ),
    .package(
      url: "https://github.com/brightdigit/Contribute.git",
      branch: "brightdigit-com-260621"
    ),
    .package(
      url: "https://github.com/brightdigit/ContributeButtondown.git",
      branch: "brightdigit-com-260717"
    ),
    .package(
      url: "https://github.com/brightdigit/ContributeMailchimp.git",
      branch: "brightdigit-com-260717"
    ),
    .package(
      url: "https://github.com/brightdigit/ContributeRSS.git",
      branch: "brightdigit-com-260717"
    ),
    .package(
      url: "https://github.com/brightdigit/ContributeYouTube.git",
      branch: "brightdigit-com-260717"
    ),
    .package(
      url: "https://github.com/brightdigit/ContributeWordPress.git",
      branch: "brightdigit-com-260406"
    ),
    .package(
      url: "https://github.com/brightdigit/PublishType.git",
      branch: "brightdigit-com-260717"
    ),
    .package(
      url: "https://github.com/brightdigit/TransistorPublishPlugin.git",
      branch: "brightdigit-com-260406"
    ),

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
        .product(name: "Contribute", package: "Contribute"),
        .product(name: "ContributeYouTube", package: "ContributeYouTube"),
        .product(name: "ContributeRSS", package: "ContributeRSS"),
        .product(name: "ContributeMailchimp", package: "ContributeMailchimp"),
        .product(name: "ContributeButtondown", package: "ContributeButtondown"),
        "ContributeWordPress",
        .product(name: "Spinetail", package: "Spinetail"),
        .product(name: "ButtondownKit", package: "ButtondownKit"),
        .product(name: "SyndiKit", package: "SyndiKit"),
        .product(name: "ConfigKeyKit", package: "ConfigKeyKit"),
        .product(name: "Configuration", package: "swift-configuration"),
      ]
    ),
    .target(
      name: "BrightDigitSite",
      dependencies: [
        "Publish",
        "YoutubePublishPlugin",
        "ReadingTimePublishPlugin",
        // "Options",
        .product(name: "PublishType", package: "PublishType"),
        "TransistorPublishPlugin",
        "NPMPublishPlugin",
        "TailwindKit"
      ]
    ),
    .target(
      name: "BrightDigitPodcast",
      dependencies: [
        .product(name: "Contribute", package: "Contribute"),
        .product(name: "ContributeYouTube", package: "ContributeYouTube"),
        .product(name: "ContributeRSS", package: "ContributeRSS"),
        .product(name: "SyndiKit", package: "SyndiKit")
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
        "BrightDigitPodcast",
        .product(name: "Spinetail", package: "Spinetail"),
        .product(name: "ButtondownKit", package: "ButtondownKit")
      ]
    ),
  ]
)
