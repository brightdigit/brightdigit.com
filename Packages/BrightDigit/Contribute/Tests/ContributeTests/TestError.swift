import Foundation

internal enum TestError: String, Error, Equatable {
  case frontMatterExport
  case markdownExtract
  case htmlExtract
  case markdownGenerate
  case makeURL
}
