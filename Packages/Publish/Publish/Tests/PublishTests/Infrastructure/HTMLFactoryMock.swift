/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Plot
import Publish

internal final class HTMLFactoryMock<Site: Website>: HTMLFactory {
  internal typealias Closure<T> = @Sendable (T, PublishingContext<Site>) throws -> Component

  // `HTMLFactory` requires `Sendable`. The test-configurable render closures
  // are injected at construction and stored immutably, so the mock is Sendable
  // without any lock-protected storage.
  private let makeIndexHTMLClosure: Closure<Index>
  private let makeSectionHTMLClosure: Closure<Section<Site>>
  private let makeItemHTMLClosure: Closure<Item<Site>>
  private let makePageHTMLClosure: Closure<Page>
  private let makeTagListHTMLClosure: Closure<TagListPage>?
  private let makeTagDetailsHTMLClosure: Closure<TagDetailsPage>?

  internal init(
    makeIndexHTML: @escaping Closure<Index> = { _, _ in HTML(.body()).node },
    makeSectionHTML: @escaping Closure<Section<Site>> = { _, _ in HTML(.body()).node },
    makeItemHTML: @escaping Closure<Item<Site>> = { _, _ in HTML(.body()).node },
    makePageHTML: @escaping Closure<Page> = { _, _ in HTML(.body()).node },
    makeTagListHTML: Closure<TagListPage>? = { _, _ in HTML(.body()).node },
    makeTagDetailsHTML: Closure<TagDetailsPage>? = { _, _ in HTML(.body()).node }
  ) {
    self.makeIndexHTMLClosure = makeIndexHTML
    self.makeSectionHTMLClosure = makeSectionHTML
    self.makeItemHTMLClosure = makeItemHTML
    self.makePageHTMLClosure = makePageHTML
    self.makeTagListHTMLClosure = makeTagListHTML
    self.makeTagDetailsHTMLClosure = makeTagDetailsHTML
  }

  internal func makeIndexHTML(
    for index: Index,
    context: PublishingContext<Site>
  ) throws -> Component {
    try makeIndexHTMLClosure(index, context)
  }

  internal func makeSectionHTML(
    for section: Section<Site>,
    context: PublishingContext<Site>
  ) throws -> Component {
    try makeSectionHTMLClosure(section, context)
  }

  internal func makeItemHTML(
    for item: Item<Site>,
    context: PublishingContext<Site>
  ) throws -> Component {
    try makeItemHTMLClosure(item, context)
  }

  internal func makePageHTML(
    for page: Page,
    context: PublishingContext<Site>
  ) throws -> Component {
    try makePageHTMLClosure(page, context)
  }

  internal func makeTagListHTML(
    for page: TagListPage,
    context: PublishingContext<Site>
  ) throws -> Component? {
    try makeTagListHTMLClosure?(page, context)
  }

  internal func makeTagDetailsHTML(
    for page: TagDetailsPage,
    context: PublishingContext<Site>
  ) throws -> Component? {
    try makeTagDetailsHTMLClosure?(page, context)
  }
}
