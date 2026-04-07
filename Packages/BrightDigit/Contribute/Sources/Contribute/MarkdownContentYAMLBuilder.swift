import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct MarkdownContentYAMLBuilder<
  SourceType,
  MarkdownExtractorType: MarkdownExtractor,
  FrontMatterExporterType: FrontMatterExporter
>: MarkdownContentBuilder where FrontMatterExporterType.SourceType == SourceType,
  MarkdownExtractorType.SourceType == SourceType
{
  private let contentFormatter: FrontMatterMarkdownFormatter = .simple

  private let frontMatterExporter: FrontMatterExporterType
  private let markdownExtractor: MarkdownExtractorType

  public init(
    frontMatterExporter: FrontMatterExporterType,
    markdownExtractor: MarkdownExtractorType
  ) {
    self.frontMatterExporter = frontMatterExporter
    self.markdownExtractor = markdownExtractor
  }

  public func content(
    from source: SourceType,
    using htmlToMarkdown: @escaping (String) throws -> String
  ) throws -> String {
    let frontMatterText = try frontMatterExporter.frontMatterText(from: source)
    let markdownText = try markdownExtractor.markdown(from: source, using: htmlToMarkdown)
    return contentFormatter.format(
      frontMatterText: frontMatterText,
      withMarkdown: markdownText
    )
  }
}
