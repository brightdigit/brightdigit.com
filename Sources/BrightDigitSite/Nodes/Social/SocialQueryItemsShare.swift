import Foundation

internal protocol SocialQueryItemsShare: SocialShare {
  static var baseURLComponents: URLComponents { get }
  func queryItems<PostableType: Postable>(for item: PostItem<PostableType>)
    -> [URLQueryItem]
}

extension SocialQueryItemsShare {
  internal func shareURL<PostableType: Postable>(for item: PostItem<PostableType>) -> URL
  {
    var urlComponents = Self.baseURLComponents
    urlComponents.queryItems = queryItems(for: item)
    guard let url = urlComponents.url else {
      preconditionFailure("Failed to construct share URL")
    }
    return url
  }
}
