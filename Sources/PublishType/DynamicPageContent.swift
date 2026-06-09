import Foundation
import Plot
import Publish

public struct DynamicPageContent<
  BuilderType: ContentBuilder,
  WebsiteType
>: PageContent where BuilderType.WebsiteType == WebsiteType {
  public var description: String {
    builder.description
  }

  public var socialTitle: String {
    title
  }

  public var socialImageURL: URL {
    context.site.url(for: builder.imagePath)
  }

  public var absoluteURL: URL {
    context.site.url(for: location)
  }

  public var canonicalURL: URL? {
    absoluteURL
  }

  internal let builder: BuilderType
  internal let location: BuilderType.LocationType
  internal let context: PublishingContext<WebsiteType>

  public var title: String {
    if let site = WebsiteType.self as? MetadataAttached.Type,
      BuilderType.self.LocationType == Index.self
    {
      return site.metadata.title
    } else {
      return location.title
    }
  }

  public var main: [Node<HTML.BodyContext>] {
    builder.main(forLocation: location, withContext: context)
  }

  public var bodyID: String? {
    location.path.string
  }

  public var bodyClasses: [String] {
    builder.bodyClasses
  }

  public var redirectURL: URL? {
    nil
  }

  public init(
    builder: BuilderType, location: BuilderType.LocationType,
    context: PublishingContext<WebsiteType>
  ) {
    self.builder = builder
    self.location = location
    self.context = context
  }
}
