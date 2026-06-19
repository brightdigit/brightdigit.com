import Publish
import XCTest

import struct Files.Folder

@testable import NPMPublishPlugin

internal final class NPMInvocationTests: XCTestCase {
  internal func testNPM() throws {
    let commandString = "npm init --yes"

    let npmCommand: NPMInvocation = try .npm(
      .init(subcommand: .init("init")) {
        .init(stringLiteral: "--yes")
      },
      withSettings: NPM.Settings(location: .folder(Folder.current)),
      andContext: MockPublishingContextable()
    )

    XCTAssertEqual(npmCommand.string, commandString)
  }

  internal func testNPMResolvesArgumentsAndOutputPaths() throws {
    let cssName = UUID().uuidString
    let outputPath: OutputPath = .file(.init(cssName))

    let invocation: NPMInvocation = try .npm(
      .init(
        subcommand: .run,
        outputRelativePaths: [outputPath],
        arguments: [.string("build"), .path(outputPath)]
      ),
      withSettings: NPM.Settings(location: .folder(Folder.temporary)),
      andContext: MockPublishingContextable()
    )

    XCTAssertEqual(invocation.npmPath, "npm")
    XCTAssertEqual(invocation.arguments, ["run", "build", "\"\(cssName)\""])
    XCTAssertEqual(invocation.string, "npm run build \"\(cssName)\"")
  }
}
