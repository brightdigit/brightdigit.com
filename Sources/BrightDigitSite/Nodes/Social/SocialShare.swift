import Foundation

protocol SocialShare: Sendable {
  func shareURL<PostableType: Postable>(for item: PostItem<PostableType>) -> URL
  var actionText: String { get }
  var nameText: String { get }
  var flaticonName: String { get }
}
