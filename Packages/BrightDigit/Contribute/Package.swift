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
      from: "6.0.0"
    ),
    // Vendored fork of scinfu/SwiftSoup `main` (f474b11, 2026-06-15) with one patch: dropped
    // `@inline(__always)` from `StringUtil.appendNormalisedWhitespaceBytes`, whose forced inlining
    // into `Element.appendNormalisedText` crashes the Swift 6.4 nightly optimizer in
    // `swift build -c release`. Restore the upstream remote once the toolchain stabilises / the
    // fix lands upstream. See CI run 27729200662.
    .package(path: "../../scinfu/SwiftSoup"),
    // Tracks `main` to match the swift-cmark `gfm` branch used across this
    // monorepo and the Swift 6.4 toolchain; pin to a tagged release once the
    // toolchain stabilises. URL standardised on `swiftlang` (matches the root
    // package) so SPM resolves a single `swift-markdown` identity.
    .package(
      url: "https://github.com/swiftlang/swift-markdown.git",
      branch: "main"
    ),
  ],
  targets: [
    .target(
      name: "Contribute",
      dependencies: [
        "Yams",
        "SwiftSoup",
        .product(name: "Markdown", package: "swift-markdown"),
      ]
    ),
    .testTarget(
      name: "ContributeTests",
      dependencies: ["Contribute"]
    )
  ]
)
