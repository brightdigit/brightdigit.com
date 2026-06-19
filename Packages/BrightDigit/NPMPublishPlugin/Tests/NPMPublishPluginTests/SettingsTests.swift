import Files
import Foundation
import Publish
import XCTest

@testable import NPMPublishPlugin

internal final class SettingsTests: XCTestCase {
  internal func testNpmPathDefaultsToNpm() {
    XCTAssertEqual(NPM.Settings(location: .folder(.temporary)).npmPath, "npm")
    XCTAssertEqual(NPM.Settings(folder: .temporary).npmPath, "npm")
    XCTAssertEqual(NPM.Settings(path: Path(".")).npmPath, "npm")
  }

  internal func testCustomNpmPathIsPreserved() {
    XCTAssertEqual(
      NPM.Settings(npmPath: "/usr/local/bin/npm", folder: .temporary).npmPath,
      "/usr/local/bin/npm"
    )
  }

  internal func testFolderLocationReturnsFolderDirectly() throws {
    let settings = NPM.Settings(location: .folder(.temporary))

    let resolved = try settings.folder(usingContext: MockPublishingContextable())

    XCTAssertEqual(resolved.path, Folder.temporary.path)
  }

  internal func testPathLocationDelegatesToContext() throws {
    let context = FolderResolvingContext(resolved: .temporary)
    let settings = NPM.Settings(path: Path("some/where"))

    let resolved = try settings.folder(usingContext: context)

    XCTAssertEqual(resolved.path, Folder.temporary.path)
    XCTAssertEqual(context.requestedPath?.string, "some/where")
  }
}
