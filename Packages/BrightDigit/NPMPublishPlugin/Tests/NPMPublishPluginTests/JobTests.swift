import Foundation
import Publish
import XCTest

import struct Files.Folder

@testable import NPMPublishPlugin

internal final class JobTests: XCTestCase {
  internal func testDesignatedInitStoresValues() {
    let path: OutputPath = .file(.init("a.css"))
    let job = NPM.Job(
      subcommand: .run,
      outputRelativePaths: [path],
      arguments: [.string("--silent")]
    )

    XCTAssertEqual(job.subcommand.string, "run")
    XCTAssertEqual(job.outputRelativePaths, [path])
    XCTAssertEqual(job.arguments.count, 1)
  }

  internal func testCIHelperBuildsCISubcommand() {
    let job = ci()

    XCTAssertEqual(job.subcommand.string, "ci")
    XCTAssertTrue(job.outputRelativePaths.isEmpty)
    XCTAssertTrue(job.arguments.isEmpty)
  }

  internal func testRunHelperBuildsRunSubcommandWithPathsAndArguments() {
    let path: OutputPath = .folder(.init("dist"))
    let job = NPMPublishPlugin.run(paths: [path]) {
      "--prod"
    }

    XCTAssertEqual(job.subcommand.string, "run")
    XCTAssertEqual(job.outputRelativePaths, [path])
    XCTAssertEqual(job.arguments.count, 1)
  }

  internal func testCreateOutputMapsPathsToRelativePaths() throws {
    let fileName = UUID().uuidString
    let path: OutputPath = .file(.init(fileName))
    let job = NPM.Job(subcommand: .run, outputRelativePaths: [path])

    let map = try job.createOutput(
      using: MockPublishingContextable(),
      relativeTo: .temporary
    )

    XCTAssertEqual(map[path], fileName)
  }
}
