/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Foundation
import Plot

// MARK: - Files and folders

extension PublishingStep {
  /// Copy the website's main resources into its output folder
  /// - Parameters:
  ///   - originPath: The path that the resource folder is located at.
  ///   - targetFolderPath: Any specific path to copy the resources to.
  ///       If `nil`, then the resources will be copied to the output folder itself.
  ///   - includeFolder: Whether the resource folder itself, or just its
  ///       contents, should be copied. Default: `false`.
  /// - Returns: The configured publishing step.
  public static func copyResources(
    at originPath: Path = "Resources",
    to targetFolderPath: Path? = nil,
    includingFolder includeFolder: Bool = false
  ) -> Self {
    copyFiles(
      at: originPath,
      to: targetFolderPath,
      includingFolder: includeFolder
    )
  }

  /// Copy a file at a given path into the website's output folder.
  /// - Parameters:
  ///   - originPath: The path of the file to copy.
  ///   - targetFolderPath: Any specific folder path to copy the file to.
  ///       If `nil`, then the file will be copied to the output folder itself.
  /// - Returns: The configured publishing step.
  public static func copyFile(
    at originPath: Path,
    to targetFolderPath: Path? = nil
  ) -> Self {
    step(named: "Copy file '\(originPath)'") { context in
      try context.copyFileToOutput(
        from: originPath,
        to: targetFolderPath
      )
    }
  }

  /// Copy a folder at a given path into the website's output folder.
  /// - Parameters:
  ///   - originPath: The path of the folder to copy.
  ///   - targetFolderPath: Any specific path to copy the folder to.
  ///       If `nil`, then the folder will be copied to the output folder itself.
  ///   - includeFolder: Whether the origin folder itself, or just its
  ///       contents, should be copied. Default: `false`.
  /// - Returns: The configured publishing step.
  public static func copyFiles(
    at originPath: Path,
    to targetFolderPath: Path? = nil,
    includingFolder includeFolder: Bool = false
  ) -> Self {
    step(named: "Copy '\(originPath)' files") { context in
      let folder = try context.folder(at: originPath)

      if includeFolder {
        try context.copyFolderToOutput(
          folder,
          targetFolderPath: targetFolderPath
        )
      } else {
        for subfolder in folder.subfolders {
          try context.copyFolderToOutput(
            subfolder,
            targetFolderPath: targetFolderPath
          )
        }

        for file in folder.files {
          try context.copyFileToOutput(
            file,
            targetFolderPath: targetFolderPath
          )
        }
      }
    }
  }
}
