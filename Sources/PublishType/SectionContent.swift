import Foundation
import Plot
import Publish

public struct SectionContent<SectionBuilderType: SectionBuilderProtocol>: PageContent {
  internal let builder: SectionBuilderType
  internal let context: PublishingContext<SectionBuilderType.WebsiteType>

  public var description: String {
    builder.description
  }

  public var socialTitle: String {
    title
  }

  public var socialImageURL: URL {
    if builder.featuredItem.featuredImageURL.path.isEmpty {
      return builder.featuredItem.featuredImageURL.absoluteURL
    } else {
      let path = Path(builder.featuredItem.featuredImageURL.path)
      return context.site.url(for: path)
    }
  }

  public var absoluteURL: URL {
    context.site.url(for: builder.section)
  }

  public var title: String {
    builder.title
  }

  public var bodyClasses: [String] {
    []
  }

  public var bodyID: String? {
    builder.section.id.rawValue
  }

  public var main: [Node<HTML.BodyContext>] {
    [
      .class("section"),
      .unwrap(builder.header1) { text in
        .header(
          .h1(.text(text))
        )
      },
      featuredNode,
      .section(
        .ol(
          .forEach(builder.children) {
            .li(
              .forEach($0.sectionItemContent) { $0 }
            )
          }
        )
      ),
    ]
  }

  public var featuredNode: Node<HTML.BodyContext> {
    builder.featuredItem.featuredItemContent
  }

  public var redirectURL: URL? {
    nil
  }

  public var canonicalURL: URL? {
    context.site.url(for: builder.section.path)
  }

  public init(
    builder: SectionBuilderType,
    context: PublishingContext<SectionBuilderType.WebsiteType>
  ) {
    self.builder = builder
    self.context = context
  }
}

extension Website {
  internal func absoluteURL(for url: URL) -> URL {
    if url.path.isEmpty || url.host != nil {
      return url
    } else {
      let path = Path(url.path)
      return self.url(for: path)
    }
  }
}
