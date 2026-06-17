// swift-tools-version:6.0
// swiftlint:disable explicit_top_level_acl
import PackageDescription

let package = Package(
  name: "SwiftTube",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9)
  ],
  products: [
    // Legacy SwagGen/Prch client. Retained until ContributeYouTube is rewired
    // onto SwiftTubeOpenAPI (#37), after which it — and Prch (#45) — are removed.
    .library(name: "SwiftTube", targets: ["SwiftTube"]),
    // New swift-openapi-generator async client.
    .library(name: "SwiftTubeOpenAPI", targets: ["SwiftTubeOpenAPI"])
  ],
  dependencies: [
    .package(url: "https://github.com/brightdigit/Prch.git", from: "0.2.1"),
    .package(
      url: "https://github.com/apple/swift-openapi-generator",
      from: "1.7.0"
    ),
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
    // Legacy SwagGen client compiled in Swift 5 mode to avoid churning the
    // ~261 generated files; it is deleted with Prch (#45) once the OpenAPI
    // client is wired into ContributeYouTube.
    .target(
      name: "SwiftTube",
      dependencies: ["Prch"],
      swiftSettings: [.swiftLanguageMode(.v5)]
    ),
    .target(
      name: "SwiftTubeOpenAPI",
      dependencies: [
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
      ],
      plugins: [
        .plugin(
          name: "OpenAPIGenerator",
          package: "swift-openapi-generator"
        )
      ]
    ),
    .testTarget(name: "SwiftTubeTests", dependencies: ["SwiftTube"]),
    .testTarget(
      name: "SwiftTubeOpenAPITests",
      dependencies: [
        "SwiftTubeOpenAPI",
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "HTTPTypes", package: "swift-http-types")
      ]
    )
  ]
)
