// swift-tools-version:6.4
// swiftlint:disable explicit_top_level_acl
import PackageDescription

let package = Package(
  name: "Spinetail",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9)
  ],
  products: [
    // swift-openapi-generator async Mailchimp Marketing API client. The legacy
    // SwagGen/Prch `Spinetail` target has been removed (#37/#45); Types.swift /
    // Client.swift are generated ahead of time by
    // Scripts/generate-openapi-spinetail.sh and committed under
    // Sources/SpinetailOpenAPI (no build plugin).
    .library(name: "SpinetailOpenAPI", targets: ["SpinetailOpenAPI"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-openapi-runtime",
      from: "1.8.0"
    ),
    .package(
      url: "https://github.com/apple/swift-openapi-urlsession",
      from: "1.0.0"
    ),
    // Transitive via swift-openapi-runtime; declared explicitly so the
    // contract tests can name HTTPRequest/HTTPResponse in their mock transport.
    .package(
      url: "https://github.com/apple/swift-http-types",
      from: "1.0.0"
    )
  ],
  targets: [
    .target(
      name: "SpinetailOpenAPI",
      dependencies: [
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
        .product(name: "HTTPTypes", package: "swift-http-types")
      ],
      exclude: [
        // Generator inputs/config live alongside the committed output but are
        // not Swift sources.
        "openapi-generator-config.yaml",
        "filtered-openapi.yaml"
      ],
      swiftSettings: [.swiftLanguageMode(.v6)]
    ),
    .testTarget(
      name: "SpinetailOpenAPITests",
      dependencies: [
        "SpinetailOpenAPI",
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "HTTPTypes", package: "swift-http-types")
      ],
      swiftSettings: [.swiftLanguageMode(.v6)]
    )
  ]
)
