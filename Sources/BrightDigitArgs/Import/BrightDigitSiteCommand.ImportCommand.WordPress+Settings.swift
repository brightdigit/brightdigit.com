import Foundation
import BrightDigitSite
import ContributeWordPress

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public extension BrightDigitSiteCommand.ImportCommand.WordPress {
  var rootPublishPathURL: URL {
    URL(
      fileURLWithPath: "",
      relativeTo: FileManager.default.currentDirectoryURL
    )
  }

  var exportsDirectoryURL: URL {
    URL(
      fileURLWithPath: wordpressExportsDirectory,
      relativeTo: FileManager.default.currentDirectoryURL
    )
  }

  var assetImportSetting: AssetImportSetting {
    switch (importAssetsDirectory, skipDownload) {
    case (.some(let directory), _):
      return .copyFilesFrom(.init(fileURLWithPath: directory, relativeTo: FileManager.default.currentDirectoryURL))
    case (.none, true):
      return .none
    default:
      return .download
    }
  }
}
