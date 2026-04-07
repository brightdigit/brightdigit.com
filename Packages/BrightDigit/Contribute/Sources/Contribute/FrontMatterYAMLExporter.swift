import Foundation
import Yams

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A type that exports front matter in YAML format.
public struct FrontMatterYAMLExporter<
  SourceType,
  FrontMatterTranslatorType: FrontMatterTranslator
>: FrontMatterExporter where FrontMatterTranslatorType.SourceType == SourceType {
  /// The front matter translator to use.
  private let translator: FrontMatterTranslatorType

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
    translator: FrontMatterTranslatorType,
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
