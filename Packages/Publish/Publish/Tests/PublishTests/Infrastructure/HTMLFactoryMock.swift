/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Publish
import Plot

final class HTMLFactoryMock<Site: Website>: HTMLFactory {
    typealias Closure<T> = @Sendable (T, PublishingContext<Site>) throws -> HTML

    // `HTMLFactory` requires `Sendable`. The test-configurable render closures
    // are injected at construction and stored immutably, so the mock is Sendable
    // without any lock-protected storage.
    private let makeIndexHTMLClosure: Closure<Index>
    private let makeSectionHTMLClosure: Closure<Section<Site>>
    private let makeItemHTMLClosure: Closure<Item<Site>>
    private let makePageHTMLClosure: Closure<Page>
    private let makeTagListHTMLClosure: Closure<TagListPage>?
    private let makeTagDetailsHTMLClosure: Closure<TagDetailsPage>?

    init(
        makeIndexHTML: @escaping Closure<Index> = { _, _ in HTML(.body()) },
        makeSectionHTML: @escaping Closure<Section<Site>> = { _, _ in HTML(.body()) },
        makeItemHTML: @escaping Closure<Item<Site>> = { _, _ in HTML(.body()) },
        makePageHTML: @escaping Closure<Page> = { _, _ in HTML(.body()) },
        makeTagListHTML: Closure<TagListPage>? = { _, _ in HTML(.body()) },
        makeTagDetailsHTML: Closure<TagDetailsPage>? = { _, _ in HTML(.body()) }
    ) {
        self.makeIndexHTMLClosure = makeIndexHTML
        self.makeSectionHTMLClosure = makeSectionHTML
        self.makeItemHTMLClosure = makeItemHTML
        self.makePageHTMLClosure = makePageHTML
        self.makeTagListHTMLClosure = makeTagListHTML
        self.makeTagDetailsHTMLClosure = makeTagDetailsHTML
    }

    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        try makeIndexHTMLClosure(index, context)
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        try makeSectionHTMLClosure(section, context)
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        try makeItemHTMLClosure(item, context)
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        try makePageHTMLClosure(page, context)
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        try makeTagListHTMLClosure?(page, context)
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        try makeTagDetailsHTMLClosure?(page, context)
    }
}
