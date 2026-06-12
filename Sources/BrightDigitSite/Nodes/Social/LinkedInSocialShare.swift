import Foundation

internal struct LinkedInSocialShare: SocialQueryItemsShare {
  internal static let baseURLComponents = URLComponents(
    staticString: "http://www.linkedin.com/shareArticle"
  )

  internal let flaticonName: String = "linkedin"

  internal let actionText: String = "Share On"
  internal let nameText: String = "LinkedIn"

  internal func queryItems<PostableType>(for item: PostItem<PostableType>)
    -> [URLQueryItem]
  where PostableType: Postable {
    var queryItems: [URLQueryItem] = []
    queryItems.append(URLQueryItem(name: "title", value: item.title))
    queryItems.append(URLQueryItem(name: "summary", value: item.description))
    queryItems.append(URLQueryItem(name: "source", value: PostableType.linkedInSource))
    queryItems.append(
      URLQueryItem(
        name: "url",
        value: item.absoluteURL.absoluteString.addingPercentEncoding(
          withAllowedCharacters: .urlQueryAllowed
        )
      )
    )
    return queryItems
  }
}
