/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct NamedURLCollection {
  private let urlsByName: [String: URL]

  internal init(urlsByName: [String: URL]) {
    self.urlsByName = urlsByName
  }

  internal func url(named name: Substring) -> URL? {
    urlsByName[name.lowercased()]
  }
}
