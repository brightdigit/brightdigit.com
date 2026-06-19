//
//  Import.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Contribute

/// Namespace for the two-token `import …` commands (issue #44).
///
/// Caseless enum used purely as a namespace; the individual commands are added
/// via extensions in their own files (``Import/PodcastCommand``,
/// ``Import/MailchimpCommand``, ``Import/WordPressCommand``).
public enum Import {
  /// The shared HTML-to-Markdown generator used by the Mailchimp and Podcast
  /// importers.
  ///
  /// The podcast and Mailchimp importers convert source HTML to
  /// Markdown through this one ``Contribute/SwiftSoupMarkdownGenerator``.
  internal static let markdownGenerator = SwiftSoupMarkdownGenerator()
}
