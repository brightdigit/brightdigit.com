import BrightDigitSite
import ContributeWordPress
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension BrightDigitSiteCommand.ImportCommand.WordPress {
  public var rootPublishPathURL: URL {
    URL(
      fileURLWithPath: "",
      relativeTo: FileManager.default.currentDirectoryURL
    )
  }

  public var exportsDirectoryURL: URL {
    URL(
      fileURLWithPath: wordpressExportsDirectory,
      relativeTo: FileManager.default.currentDirectoryURL
    )
  }

  public var assetImportSetting: AssetImportSetting {
    switch (importAssetsDirectory, skipDownload) {
    case (.some(let directory), _):
      return .copyFilesFrom(
        .init(
          fileURLWithPath: directory, relativeTo: FileManager.default.currentDirectoryURL)
      )
    case (.none, true):
      return .none
    default:
      return .download
    }
  }
}
