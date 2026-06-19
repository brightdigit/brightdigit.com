import Foundation
import Publish
import XCTest

@testable import NPMPublishPlugin

internal final class BuilderTests: XCTestCase {
  internal func testArgumentBuilderWrapsSingleArgument() {
    let result = NPM.ArgumentBuilder.buildExpression(.string("--yes"))

    XCTAssertEqual(result.count, 1)
    guard case .string(let value) = result[0] else {
      return XCTFail("expected .string case")
    }
    XCTAssertEqual(value, "--yes")
  }

  internal func testArgumentBuilderWrapsOutputPathAsPathArgument() {
    let path: OutputPath = .file(.init("a.css"))

    let result = NPM.ArgumentBuilder.buildExpression(path)

    XCTAssertEqual(result.count, 1)
    guard case .path(let wrapped) = result[0] else {
      return XCTFail("expected .path case")
    }
    XCTAssertEqual(wrapped, path)
  }

  internal func testArgumentBuilderBlockFlattensComponents() {
    let result = NPM.ArgumentBuilder.buildBlock(
      [.string("a")],
      [.string("b"), .string("c")]
    )

    XCTAssertEqual(result.count, 3)
  }

  internal func testJobBuilderCollectsJobs() {
    let jobs = NPM.JobBuilder.buildBlock(
      .init(subcommand: .ci),
      .init(subcommand: .run)
    )

    XCTAssertEqual(jobs.count, 2)
    XCTAssertEqual(jobs[0].subcommand.string, "ci")
    XCTAssertEqual(jobs[1].subcommand.string, "run")
  }

  internal func testJobBuilderInitAppliesArgumentBuilder() {
    let job = NPM.Job(subcommand: .run) {
      "--silent"
      OutputPath.file(.init("out.css"))
    }

    XCTAssertEqual(job.arguments.count, 2)
  }
}
