import XCTest

#if !canImport(ObjectiveC)
  internal func allTests() -> [XCTestCaseEntry] {
    [
      testCase(YoutubePublishPluginTests.allTests)
    ]
  }
#endif
