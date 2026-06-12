import Foundation
import Plot
import Publish

public struct ItemContent<
  ItemType: SectionItem,
  WebsiteType
>: PageContent where ItemType.WebsiteType == WebsiteType {
  internal let item: ItemType
  internal let context: PublishingContext<WebsiteType>

  public var description: String {
    item.description
  }

  public var socialTitle: String {
    item.pageTitle
  }

  public var socialImageURL: URL {
    context.site.absoluteURL(for: item.featuredImageURL)
  }

  public var absoluteURL: URL {
    item.source.absoluteURL(forSite: context.site)
  }

  public var title: String {
    item.pageTitle
  }

  public var bodyID: String? {
    item.pageBodyID
  }

  public var bodyClasses: [String] {
    [item.source.sectionID.rawValue]
  }

  public var main: [Node<HTML.BodyContext>] {
    item.pageMainContent
  }

  public var redirectURL: URL? {
    item.redirectURL
  }

  public var canonicalURL: URL? {
    redirectURL ?? absoluteURL
  }

  public init(item: ItemType, context: PublishingContext<WebsiteType>) {
    self.item = item
    self.context = context
  }
}

extension URL {
  public init(staticString: String) {
    guard let url = URL(string: staticString) else {
      preconditionFailure("Invalid static URL string: \(staticString)")
    }
    self = url
  }
}

extension Item {
  public var rootRelativeURL: URL {
    URL(staticString: "/\(path)")
  }

  public func absoluteURL(forSite site: Site) -> URL {
    site.url(for: path)
  }
}
