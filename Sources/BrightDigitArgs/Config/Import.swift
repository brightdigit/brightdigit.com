/// Namespace for the two-token `import …` commands (issue #44).
///
/// Caseless enum used purely as a namespace; the individual commands are added
/// via extensions in their own files (``Import/PodcastCommand``,
/// ``Import/MailchimpCommand``, ``Import/WordPressCommand``).
public enum Import {}
