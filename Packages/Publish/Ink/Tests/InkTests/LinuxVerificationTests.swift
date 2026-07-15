/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest

#if canImport(ObjectiveC)
  internal final class LinuxVerificationTests: XCTestCase {
    internal func testAllTestsRunOnLinux() {
      for testCase in allTests() {
        let type = testCase.testCaseClass

        let testNames: [String] = type.defaultTestSuite.tests.map { test in
          let components = test.name.components(separatedBy: .whitespaces)
          return components[1].replacingOccurrences(of: "]", with: "")
        }

        let linuxTestNames = Set(testCase.allTests.map { $0.0 })

        for name in testNames where !linuxTestNames.contains(name) {
          XCTFail(
            """
            \(type).\(name) does not run on Linux.
            Please add it to \(type).allTests.
            """
          )
        }
      }
    }
  }
#endif
