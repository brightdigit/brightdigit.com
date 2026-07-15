//
//  Newsletter.swift
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

/// The newsletter content type, importing BrightDigit newsletters from
/// Buttondown emails (issue #122).
///
/// A fresh, non-deprecated analog of `ContributeMailchimp.Newsletter`. Where the
/// Mailchimp importer fetched each campaign's archive HTML in a second request,
/// a Buttondown ``ButtondownKit/Email`` already carries its `body` HTML, so a
/// ``Source`` is built directly from the email and its `body` is converted to
/// Markdown through the shared HTML→Markdown closure by the reused
/// ``Contribute/FilteredHTMLMarkdownExtractor``.
public enum Newsletter: ContentType {
  public typealias SourceType = Source
  public typealias MarkdownExtractorType = FilteredHTMLMarkdownExtractor<Source>
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}
