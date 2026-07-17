/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest

/// Namespace for helpers that enable running the XCTest suite on Linux.
public enum Linux {}

extension Linux {
  /// A test case class paired with the manifest of tests to run for it.
  public typealias TestCase = (testCaseClass: XCTestCase.Type, allTests: TestManifest)
  /// A list of named test runners for a single test case.
  public typealias TestManifest = [(String, TestRunner)]
  /// A closure that runs a single test against a test case instance.
  public typealias TestRunner = (XCTestCase) throws -> Void
  /// A list of named tests for a concrete `XCTestCase` subclass.
  public typealias TestList<T: XCTestCase> = [(String, Test<T>)]
  /// A closure that produces a test method for a concrete `XCTestCase` subclass.
  public typealias Test<T: XCTestCase> = (T) -> () throws -> Void
}

extension Linux {
  /// Builds a ``TestCase`` from a strongly typed ``TestList``.
  internal static func makeTestCase<T: XCTestCase>(using list: TestList<T>) -> TestCase {
    let manifest: TestManifest = list.map { name, function in
      (
        name,
        { type in
          // allTests only ever supplies instances of T for this test case.
          // swiftlint:disable:next force_cast
          try function(type as! T)()
        }
      )
    }

    return (T.self, manifest)
  }
}
