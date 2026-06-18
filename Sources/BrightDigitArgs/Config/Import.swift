import Contribute

/// Namespace for the two-token `import …` commands (issue #44).
///
/// Caseless enum used purely as a namespace; the individual commands are added
/// via extensions in their own files (``Import/PodcastCommand``,
/// ``Import/MailchimpCommand``, ``Import/WordPressCommand``).
public enum Import {
  /// The shared HTML-to-Markdown generator used by the Mailchimp and Podcast
  /// importers. The podcast and Mailchimp importers convert source HTML to
  /// Markdown through this one ``Contribute/SwiftSoupMarkdownGenerator``.
  internal static let markdownGenerator = SwiftSoupMarkdownGenerator()
}
