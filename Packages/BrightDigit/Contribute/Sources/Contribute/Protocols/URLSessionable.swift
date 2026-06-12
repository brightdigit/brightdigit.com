//
//  URLSessionable.swift
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

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A protocol that defines a method for downloading data from a URL.
public protocol URLSessionable {
  /// Downloads data from the specified URL.
  ///
  /// - Parameters:
  ///   - fromURL: The URL from which the data should be downloaded.
  ///   - completion: A closure that is called when the download operation completes.
  ///   It takes three optional parameters: the downloaded data's URL, the URL response,
  ///   and any error that occurred during the download.
  func download(
    fromURL: URL,
    completion: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void
  )
}

extension URLSession: URLSessionable {
  /// Downloads data from the specified URL using a download task.
  ///
  /// - Parameters:
  ///   - fromURL: The URL from which the data should be downloaded.
  ///   - completion: A closure that is called when the download operation
  ///     completes. It takes three optional parameters: the downloaded
  ///     data's URL, the URL response, and any error that occurred during
  ///     the download.
  public func download(
    fromURL: URL,
    completion: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void
  ) {
    downloadTask(with: fromURL, completionHandler: completion)
      .resume()
  }
}
