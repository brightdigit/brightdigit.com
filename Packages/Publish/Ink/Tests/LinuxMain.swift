/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import InkTests
import XCTest

internal var tests = [XCTestCaseEntry]()
tests += InkTests.allTests()
XCTMain(tests)
