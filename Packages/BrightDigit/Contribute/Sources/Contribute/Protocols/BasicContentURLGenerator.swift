//
//  BasicContentURLGenerator.swift
//  Contribute
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

/// A `ContentURLGenerator` that builds destination URLs from a file name,
/// appending the `md` path extension.
public protocol BasicContentURLGenerator: ContentURLGenerator {
  /// Returns the file name (without extension) for the given source data.
  ///
  /// - Parameter source: The source data to generate the file name from.
  /// - Returns: A string representing the file name.
  func fileNameWithoutExtensionFromSource(_ source: SourceType) -> String
}

extension BasicContentURLGenerator {
  /// Returns a default destination URL for the given markdown source data.
  public func destinationURL(
    from source: SourceType, atContentPathURL contentPathURL: URL
  ) -> URL {
    let fileNameWithoutExtension = fileNameWithoutExtensionFromSource(source)

    return
      contentPathURL
      .appendingPathComponent(fileNameWithoutExtension)
      .appendingPathExtension("md")
  }
}
