import Foundation

internal struct BufferSocialShare: SocialQueryItemsShare {
  internal static let baseURLComponents = URLComponents(
    staticString: "https://publish.buffer.com/compose")

  internal let flaticonName: String = "buffer"

  internal let actionText: String = "Share With"
  internal let nameText: String = "Buffer"

  internal func queryItems<PostableType>(for item: PostItem<PostableType>)
    -> [URLQueryItem]
  where PostableType: Postable {
    var queryItems: [URLQueryItem] = []
    queryItems.append(URLQueryItem(name: "text", value: item.title))
    queryItems.append(
      URLQueryItem(
        name: "url",
        value: item.absoluteURL.absoluteString.addingPercentEncoding(
          withAllowedCharacters: .urlQueryAllowed)))
    return queryItems
  }
}
