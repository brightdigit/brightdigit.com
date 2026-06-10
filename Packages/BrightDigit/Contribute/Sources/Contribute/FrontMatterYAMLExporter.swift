//
//  FrontMatterYAMLExporter.swift
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
import Yams

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A type that exports front matter in YAML format.
public struct FrontMatterYAMLExporter<
  SourceType,
  TranslatorType: FrontMatterTranslator
>: FrontMatterExporter where TranslatorType.SourceType == SourceType {
  /// The front matter translator to use.
  private let translator: TranslatorType

  /// The YAML formatter to use.
  private let formatter: FrontMatterFormatter

  /// Initialize a new instance of `FrontMatterYAMLExporter`.
  ///
  /// - Parameters:
  ///   - translator: The front matter translator for translating front
  ///   matter from a source data.
  ///   - formatter: The formatter used to format the output of the translator
  ///   into YAML string.
  public init(
    translator: TranslatorType,
    formatter: FrontMatterFormatter = {
      let encoder = YAMLEncoder()
      encoder.options = .init(width: -1, allowUnicode: true)
      return encoder
    }()
  ) {
    self.translator = translator
    self.formatter = formatter
  }

  /// Exports the front matter text in YAML format from the given source data.
  ///
  /// - Parameter source: The source data to export front matter from.
  /// - Returns: The exported front matter text.
  /// - Throws: An error if the source data could not be processed.
  public func frontMatterText(from source: SourceType) throws -> String {
    let specs = translator.frontMatter(from: source)
    let frontMatterText = try formatter.format(specs)
    return frontMatterText
  }
}
