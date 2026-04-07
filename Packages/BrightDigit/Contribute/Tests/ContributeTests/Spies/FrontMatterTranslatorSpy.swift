import Contribute
import Foundation

internal final class FrontMatterTranslatorSpy: FrontMatterTranslator {
  internal private(set) var isCalled: Bool = false

  internal required init() {}

  internal func frontMatter(from _: MockSource) -> MockFrontMatter {
    isCalled = true
    return MockFrontMatter()
  }
}
