import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Generates markdown from HTML string using [Pandoc](https://pandoc.org/).
public struct PandocMarkdownGenerator: MarkdownGenerator {
  /// A namespace for temporary file operations.
  public enum Temporary {
    /// The URL of the temporary directory.
    private static let temporaryDirURL: URL = .temporaryDirURL

    /// Creates a temporary file from the given content.
    ///
    /// - Parameter content: The content of the temporary file.
    /// - Returns: The URL of the created temporary file.
    /// - Throws: An error if the temporary file creation fails.
    public static func file(fromContent content: String) throws -> URL {
      let temporaryFileURL = temporaryDirURL.appendingPathComponent(UUID().uuidString)
      try content.write(to: temporaryFileURL, atomically: true, encoding: .utf8)
      return temporaryFileURL
    }
  }

  /// The function used for executing shell commands.
  private let shellOut: (String, [String]) throws -> String

  /// The function used for creating temporary files.
  private let temporaryFile: (String) throws -> URL

  /// The path to the Pandoc executable.
  private let pandocPath = ProcessInfo.processInfo.environment["PANDOC_PATH"]
    ?? "$(which pandoc)"

  /// Initializes a new `PandocMarkdownGenerator` instance.
  ///
  /// - Parameters:
  ///   - temporaryFile: A closure that creates a temporary file from the given content.
  ///   - shellOut: A closure that executes a shell command and returns the output.
  public init(
    shellOut: @escaping (String, [String]) throws -> String,
    temporaryFile: @escaping (String) throws -> URL = Temporary.file(fromContent:)
  ) {
    self.shellOut = shellOut
    self.temporaryFile = temporaryFile
  }

  public func markdown(fromHTML htmlString: String) throws -> String {
    let temporaryFileURL = try temporaryFile(htmlString)
    return try shellOut(pandocPath, ["-f html -t markdown_strict", temporaryFileURL.path])
  }
}
