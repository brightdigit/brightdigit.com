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

    // `HTMLFactory` requires `Sendable`, so the mutable test-configurable
    // closures are stored in lock-protected boxes rather than plain `var`s.
    private let _makeIndexHTML = LockIsolated<Closure<Index>>({ _, _ in HTML(.body()) })
    private let _makeSectionHTML = LockIsolated<Closure<Section<Site>>>({ _, _ in HTML(.body()) })
    private let _makeItemHTML = LockIsolated<Closure<Item<Site>>>({ _, _ in HTML(.body()) })
    private let _makePageHTML = LockIsolated<Closure<Page>>({ _, _ in HTML(.body()) })
    private let _makeTagListHTML = LockIsolated<Closure<TagListPage>?>({ _, _ in HTML(.body()) })
    private let _makeTagDetailsHTML = LockIsolated<Closure<TagDetailsPage>?>({ _, _ in HTML(.body()) })

    var makeIndexHTML: Closure<Index> {
        get { _makeIndexHTML.value }
        set { _makeIndexHTML.value = newValue }
    }
    var makeSectionHTML: Closure<Section<Site>> {
        get { _makeSectionHTML.value }
        set { _makeSectionHTML.value = newValue }
    }
    var makeItemHTML: Closure<Item<Site>> {
        get { _makeItemHTML.value }
        set { _makeItemHTML.value = newValue }
    }
    var makePageHTML: Closure<Page> {
        get { _makePageHTML.value }
        set { _makePageHTML.value = newValue }
    }
    var makeTagListHTML: Closure<TagListPage>? {
        get { _makeTagListHTML.value }
        set { _makeTagListHTML.value = newValue }
    }
    var makeTagDetailsHTML: Closure<TagDetailsPage>? {
        get { _makeTagDetailsHTML.value }
        set { _makeTagDetailsHTML.value = newValue }
    }

    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        try makeIndexHTML(index, context)
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        try makeSectionHTML(section, context)
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        try makeItemHTML(item, context)
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        try makePageHTML(page, context)
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        try makeTagListHTML?(page, context)
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        try makeTagDetailsHTML?(page, context)
    }
}
