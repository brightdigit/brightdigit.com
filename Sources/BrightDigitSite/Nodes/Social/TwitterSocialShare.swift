import Foundation

internal struct TwitterSocialShare: SocialQueryItemsShare {
  internal static let baseURLComponents = URLComponents(
    staticString: "https://twitter.com/intent/tweet")

  internal let flaticonName: String = "twitter"

  internal let actionText: String = "Share On"
  internal let nameText: String = "Twitter"

  internal func queryItems<PostableType>(for item: PostItem<PostableType>)
    -> [URLQueryItem]
  where PostableType: Postable {
    var queryItems: [URLQueryItem] = []
    queryItems.append(URLQueryItem(name: "text", value: item.title))
    queryItems.append(URLQueryItem(name: "url", value: item.absoluteURL.absoluteString))
    queryItems.append(URLQueryItem(name: "via", value: PostableType.twitterSource))
    return queryItems
  }
}
