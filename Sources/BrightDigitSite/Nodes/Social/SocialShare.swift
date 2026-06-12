import Foundation

internal protocol SocialShare: Sendable {
  var actionText: String { get }
  var nameText: String { get }
  var flaticonName: String { get }
  func shareURL<PostableType: Postable>(for item: PostItem<PostableType>) -> URL
}
