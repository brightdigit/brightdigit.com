import Contribute

/// Shared support for the migrated `import` commands (issue #44).
///
/// Holds the single ``Contribute/SwiftSoupMarkdownGenerator`` instance previously
/// exposed as `BrightDigitSiteCommand.ImportCommand.markdownGenerator`. The
/// podcast, Mailchimp, and WordPress importers all convert source HTML to
/// Markdown through this one generator.
internal enum ImportSupport {
  /// The shared HTML-to-Markdown generator used by every importer.
  internal static let markdownGenerator = SwiftSoupMarkdownGenerator()
}
