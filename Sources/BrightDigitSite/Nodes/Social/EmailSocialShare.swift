import Foundation

internal struct EmailSocialShare: SocialQueryItemsShare {
  internal static let baseURLComponents = URLComponents(staticString: "mailto:")

  internal let flaticonName: String = "newsletter"

  internal let actionText: String = "Share With"
  internal let nameText: String = "Email"

  internal func queryItems<PostableType>(for item: PostItem<PostableType>)
    -> [URLQueryItem]
  where PostableType: Postable {
    var queryItems: [URLQueryItem] = []
    queryItems.append(URLQueryItem(name: "subject", value: item.title))
    queryItems.append(
      URLQueryItem(name: "body", value: "\(item.description)\n\n\(item.absoluteURL)")
    )
    return queryItems
  }
}
